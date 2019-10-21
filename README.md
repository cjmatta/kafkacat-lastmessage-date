# kafkacat-lastmessage-date
Bash shell that uses Kafkacat to determine the date/time of the latest record on a topic

**Prerequisite**: [Kafkacat](https://github.com/edenhill/kafkacat)

### Usage
```
./kafkacat-lastmessage-date.sh -F ~/.ccloud/kafkacat-config [--topic topicname]

  note: a list of topics can be specified with a quoted string: '--topic "topic1 topic2"'
```
