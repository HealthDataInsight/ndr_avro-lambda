from ast import Lambda
from diagrams import Diagram, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.storage import S3
from diagrams.aws.general import InternetAlt2

with Diagram("NDRImport Avro Lambda", show=False):
    avroLambda = Lambda("ETL")
    
    S3("inbox") \
        >> Edge(label="Create trigger") \
        >> avroLambda

    avroLambda >> Edge(label="HTTPS request") << InternetAlt2("Transformation markup")

    avroLambda >> S3("outbox")
