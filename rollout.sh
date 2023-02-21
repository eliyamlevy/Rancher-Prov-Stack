case $1 in

    plan)
        source variables.sh
        terraform plan
    ;;

    apply)
        source variables.sh
        terraform apply --auto-approve
    ;;

    check)
        export KUBECONFIG=`pwd`/kube_config_tf-rke-config.yaml
        echo "\nGetting Nodes"
        kubectl get nodes
        echo "\nCheck Status"
        kubectl --kubeconfig=kube_config_tf-rke-config.yaml get pods --all-namespaces
    ;;

    cluster)
        rke up --config tf-rke-config.yaml
    ;;

    helm)
        
        # export KUBECONFIG=`pwd`/kube_config_tf-rke-config.yaml
        unset KUBECONFIG


        helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

        kubectl get ns | grep -w "cattle-system" 2>&1 || kubectl create namespace cattle-system

        kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

        helm repo add jetstack https://charts.jetstack.io

        helm repo update

        helm upgrade --install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.5.1

        kubectl get pods --namespace cert-manager

        kubectl -n cert-manager rollout status deploy/cert-manager

        if [[ -z "$2" ]]; then
            echo "No image tag passed in, using v2.7-head by default"

            helm upgrade --install rancher rancher-latest/rancher \
            --namespace cattle-system \
            --set hostname="eli.eng.rancher.space" \
            --set bootstrapPassword=admin \
            --set rancherImageTag=v2.7-head \
            # --set useBundledSystemChart=true \
            # --set ingress.tls.source=rancher

        else
            echo "Checking if rancherImageTag $2 exists"

            if docker manifest inspect rancher/rancher:$2 > /dev/null > 2&>1 ;then
                echo "Tag $2 exists, installing rancher now"
                helm upgrade --install rancher rancher-latest/rancher \
                --namespace cattle-system \
                --set hostname="eli.eng.rancher.space" \
                --set bootstrapPassword=admin \
                --set rancherImageTag=$2  
            else
                echo "That rancher image tag does not exist."  
            fi       
        fi
        
        kubectl -n cattle-system rollout status deploy/rancher

    ;;

    clean)
        rke remove --config tf-rke-config.yaml
        terraform destroy -target aws_instance.local-node --auto-approve
    ;;

    *)
        echo "./rollout [plan] [apply] [cluster] [check] [helm {rancherImageTag}] [clean]"
        echo "\t if you do not set a value for rancherImageTag it will use 'v2.7-head'"
    ;;

esac
