## Install Kafka

### Install Java and Bookeeper
```
sudo apt-get update
sudo apt-get install default-jre
```

Install zookeeper
```
sudo apt-get install zookeeperd
```

check zookeeper service alive
```
telnet localhost 2181
```

### Install Kafka
https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04


### Testing
Create topic
```
~/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic TutorialTopic
```
zookeeper bind on port 2181