# Job

Job là một resource cho phép pod thực hiện công việc đó chỉ 1 lần đến khi hoàn thành và kết thúc pod đó luôn.

VD:

```md
apiVersion: batch/v1
kind: Job
metadata:
    name: batch-job
spec:
    template:
        metadata:
            labels:
                app: batch-job
        spec:
            restartPolicy: OnFailure
            containers:
            - name: main
                image: luksa/batch-job
```

## CronJob

Khi chúng ta cần chạy một job nào đó vào thời điểm nhất định, ta sử dụng Cronjob.

VD:

```md
apiVersion: batch/v1beta1
kind: CronJob
metadata:
    name: batch-job-every-fifteen-minutes
spec:
    schedule: "0,15,30,45 * * * *"
    startingDeadlineSeconds: 15
    jobTemplate:
        spec:
            template:
                metadata:
                    labels:
                        app: periodic-batch-job
                spec:
                    restartPolicy: OnFailure
                    containers:
                    - name: main
                        image: luksa/batch-job
```

Giá trị trong `schedule` tương ưng với cronjob trong linux

Trong trường hợp muốn job chạy không quá muộn (Do pod chạy job đó bị tạo chậm...) sử dụng `startingDeadlineSeconds`, khi đó nếu như sau khoảng thời gian đã định mà job không chạy thì sẽ bỏ qua không chạy nữa.
