## Giới thiệu
Apache Kafka là một nền tảng stream dữ liệu phân tán (message broker)

Một stream platform sẽ có 3 khả năng chính:
  Publish và subscribe vào các stream của các bản ghi, tương tự như một hàng chờ tin nhắn.
  Các stream của các bản ghi được lưu trữ bằng phương pháp chịu lỗi cao cũng như khả năng chịu tải.
  Xử lý các stream của các bản ghi mỗi khi có bản ghi mới.

image.png

## Cấu trúc của Kafka
![image](https://user-images.githubusercontent.com/72189639/228626137-e6a7df3d-ae7d-4793-8d7e-ab900e6c473b.png)

Mô hình cấu trúc đơn giản

![image](https://user-images.githubusercontent.com/72189639/228626228-81f9e132-fbe7-4145-ad68-d429346d2a66.png)

Mô hình cấu trúc chi tiết

<b>Producer</b>: Một producer có thể là bất kì ứng dụng nào có chức năng publish message vào một topic.

<b>Messages</b>: Messages đơn thuần là byte array và developer có thể sử dụng chúng để lưu bất kì object với bất kì format nào - thông thường là String, JSON và Avro

<b>Topic</b>: Một topic là một category hoặc feed name nơi mà record được publish.

<b>Partitions</b>: Các topic được chia nhỏ vào các đoạn khác nhau, các đoạn này được gọi là partition

<b>Consumer</b>: Một consumer có thể là bất kì ứng dụng nào có chức năng subscribe vào một topic và tiêu thụ các tin nhắn.

</b>Broker</b>: Kafka cluster là một set các server, mỗi một set này được gọi là 1 broker

<b>Zookeeper</b>: được dùng để quản lý và bố trí các broker. zookeeper bind on port 2181


### Example 
Assume we have a Kafka cluster consisting of three brokers (broker1, broker2, broker3) and we want to create a new topic called "my_topic" with three partitions and a replication factor of two. To create this topic, we would perform the following steps:

1,Connect to the Zookeeper instance that is running in our Kafka cluster.

2,Issue a command to create the topic "my_topic" with three partitions and a replication factor of two.

3, Zookeeper will receive this request and update the metadata about the Kafka cluster, including the topic "my_topic" and the three partitions.

4, Zookeeper will then distribute this metadata to all the Kafka brokers in the cluster, including broker1, broker2, and broker3.

5, The Kafka brokers will use this updated metadata to create the three partitions of "my_topic" and assign two of them to each broker for replication.

6, Producers can then begin publishing messages to the "my_topic" topic, and Kafka will handle replication and distribution of these messages to the appropriate partitions and brokers.

7, Consumers can subscribe to the "my_topic" topic and begin consuming messages from the partitions assigned to them. The consumer's offset information will be stored in Zookeeper, allowing it to resume consuming from where it left off in case of failure or restart.

In this example, we can see how Zookeeper is used to manage and coordinate the Kafka cluster, including creating topics, assigning partitions to brokers, and tracking the state of the Kafka brokers and consumers.


### Kafka Visualisation
https://softwaremill.com/kafka-visualisation/
hello