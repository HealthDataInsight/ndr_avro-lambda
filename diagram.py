from ast import Lambda
from diagrams import Diagram, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.storage import S3
from diagrams.aws.general import InternetAlt2

graph_attr = {
    "pad": "1,0.25"
}

with Diagram("NDRImport Avro Lambda", show=False, graph_attr=graph_attr):
    avroLambda = Lambda("ETL")
    
    S3("inbox") \
        >> Edge(label="Create trigger") \
        >> avroLambda

    avroLambda >> Edge(label="HTTPS request") << InternetAlt2("Transformation markup")

    avroLambda >> S3("outbox")
