#!/bin/zsh
printf "\n~~~~~~ Removing Old Client Bundle if there is any~~~~~~ \n"
if [[ -f bundle.zip ]] 
    then rm -rf bundle.zip
fi
if [[ -d client-bundle ]] 
    then rm -rf client-bundle
fi

printf "\n~~~~~~ Downloading the client bundle ~~~~~~~\n"
UCP_URL=$(terraform show | sed -n '/Outputs:/,//p' | grep https | awk -F '"' '{print $2}')
AUTHTOKEN=$(curl -sk -d '{"username": "admin","password":"dockeradmin"}' ${UCP_URL}/auth/login | jq -r .auth_token)
curl -k -H "Authorization: Bearer $AUTHTOKEN" ${UCP_URL}/api/clientbundle -o bundle.zip
mkdir client-bundle
unzip bundle.zip -d client-bundle
cd client-bundle
printf "\n~~~~~~ Activating the client bundle ~~~~~~~\n"
eval "$(printenv | grep AWS)"
eval "$(<env.sh)"
cd ..

printf "\n~~~~~~ Testing client bundle with kubectl~~~~~~ \n"
kubectl get nodes || ( printf "Not working. May be credential issue" && exit 1 )

printf "\n~~~~~~ Testing client bundle with docker-cli~~~~~~ \n"
docker node ls && printf "\n~~~~~~ Yeeeeup, working !! ~~~~~~ \n" || ( printf "Not working. May be credential issue" && exit 1 )

bash