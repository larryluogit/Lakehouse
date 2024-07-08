# Trino and Iceberg REST Catalog Demo

## Start containers

```bash
docker compose up -d
```

This will initialize `iceberg` catalog in Trino.

## Initialize `test` schema

There is a simple SQL script to initialize a test schema
in the `iceberg` catalog by copying TPCH "tiny" schema from the Trino:

```bash
docker exec -it trino trino -f /home/trino/test-schema.sql
```

This is not required. It is possible to create other schemata in the `iceberg`
catalog and create and populate tables there in any way.

## Running queries

Connect to Trino CLI and execute queries:

```bash
docker exec -it trino trino
```

Inspect warehouse bucket contents: open [Minio Admin panel](http://localhost:9001)
(user name: `admin` password: `password`).


# Kafka Iceberg Streaming

This repo provides a demo of the [Apache Iceberg Sink Connector for Kafka Connect](https://github.com/tabular-io/iceberg-kafka-connect) you can execute locally with docker compose

It extends the [docker-spark-iceberg](https://github.com/tabular-io/docker-spark-iceberg) example, so you can also use this environment to test anything related to Iceberg

## Docker Compose Details

- redpanda: Just like Kafka but simpler to setup
- connect: Adds the Kafka Connect and the Iceberg Sink Connector settings
- console: Redpanda UI
- minio: Object storage compatible with Amazon S3
- mc: mc CLI to create a Minio bucket
- spark-iceberg: Spark + Iceberg environment
- rest: Rest catalog to interact with Iceberg

### Redpanda

You can acces the Redpanda UI at http://localhost:18080, there's two main screens you should look at, `Topics` and `Connectors`

The `control-iceberg` topic it's used by the connector while `payments` is the one you going to publish the messages

![Alt text](/assets/topics.png)

You'll probabily want to wait until the IcebergSinkConnector be up and running before start publishing at the Topic, just like the image below

![Alt text](/assets/connector.png)

During the producer execution you can also monitor the screen to check if the connector got any error

The table can be created in trino
```sql
    CREATE TABLE IF NOT EXISTS iceberg.orders.payments (  
        id                                                   VARCHAR,
        type                                                 VARCHAR,
        created_at                                           TIMESTAMP,
        document                                             VARCHAR,
        payer                                                VARCHAR,
        amount                                               INT
    )
    WITH (format = 'parquet', partitioning = ARRAY['document']);
```



### Minio

You can acces the Minio UI at http://localhost:9000, it will require an user and a password, (user name: `admin` password: `password`).

The mc CLI will create a bucket called `warehouse` during the docker compose execution, also a dataset and a table will be created by the spark-iceberg container

The script that creates both dataset and table can be found at `/spark/create_table.py`

### Spark-Iceberg

You can open the jupyter lab at http://localhost:8888/lab/tree/notebooks and use the sample notebook to query the table

Refer to [docker-spark-iceberg](https://github.com/tabular-io/docker-spark-iceberg) to check more details about it

### rpk

rpk it's declarative way of building stream processing and is used as the message producer in this example 

The `benthos.json.kafka.yaml` file describes the pipeline, it will consume from the file located at `data/*` and will publish to the `payments` Kafka topic

Installing: need to be installed locally
To make it simpler, you can also run with `make produce`


