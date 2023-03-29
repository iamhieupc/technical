## Continous Integration: Hệ thống sử dụng gitlab-ci để build image, test, push image lên hub
## Continous Deploy: Hệ thống sử dụng Argo-CD để thực hiện update image and sync new pod in Kubernetes

### Các bước thực hiện
#### Có 1 repo service: Có file .gitlab-ci.yml

#### Có 1 repo charts
Repo này chứa các helm chart được viết ra để  deploy các resource lên hệ thống cụm kubernetes

#### Có 1 repo ci-template
Repo này chứa các action: build, test, push image,... Là nơi mà phần gitlab.ci ở các service gọi đến

#### Có 1 repo DEV-SERVER
Repo này định nghĩa các các path của nginx để  setup ingress đến service 

### Bắt đầu thực hiện thôi nào

#### Định nghĩa gitlab-ci.yml ở repo service
File .gitlab-ci.yml có nội dung như nhau:
```
include:
  - project: 'devops-team/gitops/ci-template'
    file: 'hn-backend-ci-template.yml'
```

File này sẽ gọi đến file hn-backend-ci-template.yml trong repo ci-template

Trong file hn-backend-ci-template.yml có thực hiện 4 stages:
```
stages:
  - build
  - deploy
  - restart
  - notify
```
##### Build
Khi build thì gọi đến hàm <b>BuildBackendWithCache</b> trong file ci-function.sh
Content in this fucntion:
```
function BuildBackendWithCache(){
    # docker login -u "$HUB_USERNAME" -p "$HUB_PASSWORD" $REGISTRY
    docker pull $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG || true
    docker build --cache-from $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG -t $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG .
    docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$LATEST_TAG
    docker push $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG
    docker image rm $REGISTRY/$HUB_NAMESPACE/$IMAGE:$TAG
    # docker logout
}
```
Nói chung bước build này chỉ là build image and push image đó lên hub

##### deploy 
script gọi để deploy
```
- |
      export HN_VALUES_FILE="values_stg2_hn.yaml"
    - DeployV2
```
Hàm DeployV2 trong file ci-function.sh có nội dung như sau:
```
function DeployV2(){
  local NEW_TAG_LOCAL BRANCH_LOCAL OLD_TAG_LOCAL   # Khai báo các biến trên
  local TMPDIR=$(mktemp -u -d)                     # Khai báo 1 file tạm

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

  # Các bước bên trên là để check job để gán giá trị các biến tag
    NEW_TAG_LOCAL: tag mới của image
    BRANCH_LOCAL: đây là nhánh được tạo ngẫu nhiên, hơi khó hiểu tí
    VALUES_FILE_PATH: 
      APPLICATION=$PREFIX_APPLICATION/$IMAGE
        IMAGE: $CI_PROJECT_NAME
          CI_PROJECT_NAME: là tên repo
        PREFIX_APPLICATION: "backend"
      HCM_VALUES_FILE: Là file values.yaml trong repo charts
    Giả sử tên repo là serverless-backend => VALUES_FILE_PATH = backend/serverless-backend/hn-values.yml


  mkdir -p $TMPDIR    # tạo 1 dir
  cd $TMPDIR
  git init            #khởi tạo git
  git config --global user.email "gitops_bot@vccloud.vn"      
  git config --global user.name "GITOPS BOT"
  git remote add origin $GITOPS_URL
    # GITOPS_URL = "https://$GITOPS_USER:$GITOPS_TOKEN@git.paas.vn/devops-team/kubernetes/charts.git" ===>>> cái này là repo charts

  set +e
  git push origin --delete $BRANCH_LOCAL
  set -e

  git checkout -b $BRANCH_LOCAL || echo "dung\` ba^m' deploy nua~"  # checkout sang nhánh khác
  git sparse-checkout set $VALUES_FILE_PATH   # set valuefile
  git pull origin master --depth=25     # pull code từ master về nhánh kia
  OLD_TAG_LOCAL=$(awk -F':' '$1 ~ /tag$/ {print $2}' $VALUES_FILE_PATH | xargs) # Lấy ra image cũ
  sed -i "s/$OLD_TAG_LOCAL/$NEW_TAG_LOCAL/g" $VALUES_FILE_PATH   # đổi image cũ thành image mới
  git add $VALUES_FILE_PATH   
  git commit -m "$APPLICATION: Update tag from $OLD_TAG_LOCAL $NEW_TAG_LOCAL"
# git push -u origin $BRANCH_LOCAL
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
```

Như vậy là đã xong phần setup thay đổi image tag trong helm charts

#### Setup argo-CD
<a>https://argo-cd.readthedocs.io/en/stable/getting_started/</a>
Login vào argoCD và tạo app
Tạo hook tren gitlab để  link đến url của argoCD để khi push hoặc merge code vào 1 nhánh trên gitlab thì agroCD sẽ tự động sync pod mới trên cụm K8S





