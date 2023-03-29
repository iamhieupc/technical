#!/bin/bash

function GetValuesByBranch(){
    if [[ $CI_COMMIT_REF_NAME == "develop" ]];then
	set -o allexport
	VALUES_FILE="values_dev_hn.yaml"
	HN_VALUES_FILE="values_dev_hn.yaml"
	HCM_VALUES_FILE="values_dev_hcm.yaml"
	TAG=d${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HN_TAG=dhn${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HCM_TAG=dhcm${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	LATEST_TAG=d-latest
	HN_LATEST_TAG=dhn-latest
	HCM_LATEST_TAG=dhcm-latest
	set +o allexport

    elif [[ $CI_COMMIT_REF_NAME == "staging" || $CI_COMMIT_REF_NAME == "ci#test-staging" || $CI_COMMIT_REF_NAME =~ ^test ]];then
	set -o allexport
	VALUES_FILE="values_stg_hn.yaml"
	HN_VALUES_FILE="values_stg_hn.yaml"
	HCM_VALUES_FILE="values_stg_hcm.yaml"
	PRIVATE_VALUES_FILE="values_stg_prv.yaml"
	TAG=s${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HN_TAG=shn${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HCM_TAG=shcm${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	LATEST_TAG=s-latest
	HN_LATEST_TAG=shn-latest
	HCM_LATEST_TAG=shcm-latest
	set +o allexport

    elif [[ $CI_COMMIT_REF_NAME == "staging2" ]];then
	set -o allexport
	VALUES_FILE="values_stg2_hn.yaml"
	HN_VALUES_FILE="values_stg2_hn.yaml"
	HCM_VALUES_FILE="values_stg2_hcm.yaml"
	TAG=s${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HN_TAG=shn${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HCM_TAG=shcm${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	LATEST_TAG=s-latest
	HN_LATEST_TAG=shn-latest
	set +o allexport

    elif [[ $CI_COMMIT_REF_NAME == "master" || $CI_COMMIT_REF_NAME == "production" || $CI_COMMIT_REF_NAME == "main" || $CI_COMMIT_REF_NAME == "product" ]];then
	set -o allexport
	VALUES_FILE="values_prod_hn.yaml"
	HN_VALUES_FILE="values_prod_hn.yaml"
	HCM_VALUES_FILE="values_prod_hcm.yaml"
	PRIVATE_VALUES_FILE="values_prod_prv.yaml"
	TAG=p${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HN_TAG=phn${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	HCM_TAG=phcm${CI_PIPELINE_ID}_${CI_COMMIT_SHORT_SHA}
	LATEST_TAG=p-latest
	HN_LATEST_TAG=phn-latest
	HCM_LATEST_TAG=phcm-latest
	set +o allexport
    fi

}

function BuildFrontendWithCache(){
    local TAG_LOCAL LATEST_TAG_LOCAL
    if [[ $CI_JOB_NAME =~ ^build_hn ]];then
	TAG_LOCAL=$HN_TAG
	LATEST_TAG_LOCAL=$HN_LATEST_TAG
    elif [[ $CI_JOB_NAME =~ ^build_hcm ]];then
	TAG_LOCAL=$HCM_TAG
	LATEST_TAG_LOCAL=$HCM_LATEST_TAG
    else
	echo "error"
	exit 1
    fi
    # docker login -u "$HUB_USERNAME" -p "$HUB_PASSWORD" $REGISTRY
    # docker pull $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG_LOCAL || true
    docker build $1 --cache-from $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG_LOCAL --target builder  -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG_LOCAL .
    docker build $1 --cache-from $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG_LOCAL -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG_LOCAL .
    # docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG_LOCAL
    docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG_LOCAL
    docker image rm $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG_LOCAL
    # docker logout
}

function BuildFrontendWithoutCache(){
    local TAG_LOCAL LATEST_TAG_LOCAL
    if [[ $CI_JOB_NAME =~ ^deploy_hn ]];then
	TAG_LOCAL=$HN_TAG-wtc
    elif [[ $CI_JOB_NAME =~ ^deploy_hcm ]];then
	TAG_LOCAL=$HCM_TAG-wtc
    else
	echo "error"
	exit 1
    fi
    # docker login -u "$HUB_USERNAME" -p "$HUB_PASSWORD" $REGISTRY
    docker build $1 --no-cache -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG_LOCAL .
    docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG_LOCAL
    docker image rm $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG_LOCAL
    # docker logout
}

function BuildBackendWithCache(){
    # docker login -u "$HUB_USERNAME" -p "$HUB_PASSWORD" $REGISTRY
    docker pull $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG || true
    docker build --cache-from $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG .
    docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG
    docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG
    docker image rm $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG
    # docker logout
}

function BuildCustom(){
    local dockerfilePath=$1
    local image=$2
    local tag=$3
    local args
    if [[ -n "$4" ]];then
      args=$4
    fi

    docker pull $image:latest || true
    docker build $args --cache-from $image:latest -t $image:latest -t $image:$tag --file="$dockerfilePath" .
    docker push $image:latest
    docker push $image:$tag
    # docker image rm $image:$tag
}

function SparseCheckout(){
    local tmpdir=$(mktemp -u -d)
    local branch=$1
    local values_file_path=$2
    mkdir -p $tmpdir
    cd $tmpdir
    git init
    git config --global user.email "gitops_bot@vccloud.vn"
    git config --global user.name "GITOPS BOT"
    git remote add origin $GITOPS_URL
    set +e
    git push origin --delete $branch
    set -e
    git checkout -b $branch
    git sparse-checkout set $values_file_path
    git pull origin master --depth=25
}

function UpdateTagByYq(){
    local values_file_path=$(find . -type f -name "values*")
    local tagLocation=$1
    local newTag=$2
    local oldTag=$(yq e "$tagLocation" $values_file_path)
    yq e "$tagLocation = \"$newTag\"" -i $values_file_path
}

function CreateMR(){
    local oldTag=$1
    local newTag=$2
    # get the current branch name only
    local branch=$(git rev-parse --abbrev-ref HEAD)
    git add .
    git commit -m "$CI_PROJECT_NAME: Update tag from $oldTag to $newTag"
    git push -u origin $branch -o merge_request.create -o merge_request.merge_when_pipeline_succeeds -o merge_request.target=master -o merge_request.remove_source_branch -o merge_request.title="$CI_PROJECT_NAME: Update tag from $oldTag to $newTag"
}

function CheckMR(){
    # local branch=$(git rev-parse --abbrev-ref HEAD)
    local branch=$1
    git checkout master
    END_TIME=$((SECONDS+180))
    set +e
    while [ $SECONDS -lt $END_TIME ];do
	git pull origin master
	git log --merges --oneline | grep $branch
	if [[ $? -eq 0 ]];then
	    echo "Update tag successfully"
	    exit 0
	fi
	sleep 5
    done
    echo "update failed"
    set -e
    exit 1
}

# function GetValuesByBranchV3(){
# }

# function DeployV3(){
#     local tag=$1
#     local branch=gitops_bot-"$tag"
#     local values_file_path=$
#     SparseCheckout
    
# }

function DeployV2(){
    local NEW_TAG_LOCAL BRANCH_LOCAL OLD_TAG_LOCAL
    local TMPDIR=$(mktemp -u -d)

    if [[ $CI_JOB_NAME =~ ^deploy && $CI_JOB_NAME =~ hn$ ]];then
	NEW_TAG_LOCAL=$TAG
        BRANCH_LOCAL=gitops_bot-hn-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$HN_VALUES_FILE
    elif [[ $CI_JOB_NAME =~ ^deploy && $CI_JOB_NAME =~ hcm$ ]];then
	NEW_TAG_LOCAL=$TAG
        BRANCH_LOCAL=gitops_bot-hcm-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$HCM_VALUES_FILE
    elif [[ $CI_JOB_NAME =~ ^deploy && $CI_JOB_NAME =~ private$ ]];then
	NEW_TAG_LOCAL=$TAG
        BRANCH_LOCAL=gitops_bot-private-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$PRIVATE_VALUES_FILE
    elif [[ $CI_JOB_NAME =~ ^deploy_hn && $CI_JOB_NAME =~ without_cache$ ]];then
	NEW_TAG_LOCAL=$HN_TAG-wtc
        BRANCH_LOCAL=gitops_bot-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$HN_VALUES_FILE
    elif [[ $CI_JOB_NAME =~ ^deploy_hn ]];then
	NEW_TAG_LOCAL=$HN_TAG
        BRANCH_LOCAL=gitops_bot-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$HN_VALUES_FILE

    elif [[ $CI_JOB_NAME =~ ^deploy_hcm && $CI_JOB_NAME =~ without_cache$ ]];then
	NEW_TAG_LOCAL=$HCM_TAG-wtc
        BRANCH_LOCAL=gitops_bot-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$HCM_VALUES_FILE

    elif [[ $CI_JOB_NAME =~ ^deploy_hcm ]];then
	NEW_TAG_LOCAL=$HCM_TAG
        BRANCH_LOCAL=gitops_bot-${NEW_TAG_LOCAL}
	VALUES_FILE_PATH=${APPLICATION}/$HCM_VALUES_FILE
    fi

    mkdir -p $TMPDIR
    cd $TMPDIR
    git init
    git config --global user.email "gitops_bot@vccloud.vn"
    git config --global user.name "GITOPS BOT"
    git remote add origin $GITOPS_URL
    set +e
    git push origin --delete $BRANCH_LOCAL
    set -e
    git checkout -b $BRANCH_LOCAL || echo "dung\` ba^m' deploy nua~"
    git sparse-checkout set $VALUES_FILE_PATH
    git pull origin master --depth=25
    OLD_TAG_LOCAL=$(awk -F':' '$1 ~ /tag$/ {print $2}' $VALUES_FILE_PATH | xargs)
    sed -i "s/$OLD_TAG_LOCAL/$NEW_TAG_LOCAL/g" $VALUES_FILE_PATH
    git add $VALUES_FILE_PATH
    git commit -m "$APPLICATION: Update tag from $OLD_TAG_LOCAL $NEW_TAG_LOCAL"
#    git push -u origin $BRANCH_LOCAL
    git push -u origin $BRANCH_LOCAL -o merge_request.create -o merge_request.merge_when_pipeline_succeeds -o merge_request.target=master -o merge_request.remove_source_branch -o merge_request.title="$IMAGE: Update tag from $OLD_TAG_LOCAL $NEW_TAG_LOCAL"
    # cd ../ && rm -rf $TMPDIR
    git checkout master

    END_TIME=$((SECONDS+180))
    set +e
    while [ $SECONDS -lt $END_TIME ];do
	git pull origin master
	git log --merges --oneline | grep $BRANCH_LOCAL
	if [[ $? -eq 0 ]];then
	    echo "Update tag successfully"
	    exit 0
	fi
	sleep 5
    done
    echo "update failed"
    set -e
    exit 1
}

function Restart(){
    ARGOCD_APP_PREFIX=`echo $CI_JOB_NAME | awk -F'_' '{print $2}'`
    if [[ -n "$1" ]];then
	ARGOCD_APP_NAME=$ARGOCD_APP_PREFIX-$1
    else
	ARGOCD_APP_NAME=$ARGOCD_APP_PREFIX-$IMAGE
    fi
    argocd login $ARGOCD_URL --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --grpc-web
    DEPLOYMENT_LIST=(`argocd app actions list $ARGOCD_APP_NAME --grpc-web | awk "/apps/"' { print $3 }'`)

    for deployment in "${DEPLOYMENT_LIST[@]}";do
	echo "argocd app actions run $ARGOCD_APP_NAME restart --kind Deployment --resource-name $deployment"
	argocd app actions run $ARGOCD_APP_NAME restart --kind Deployment --resource-name $deployment
    done

}

function Notify(){
    curl -X POST -d chat_id=$CHAT_ID -d text="JOB in PIPELINE $CI_PIPELINE_URL failed" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}
