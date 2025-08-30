import json, apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, StandardOptions

class Parse(beam.DoFn):
    def process(self, msg):
        d = json.loads(msg)
        yield {
            "order_id": int(d["order_id"]),
            "customer_id": int(d["customer_id"]),
            "amount": float(d["amount"]),
            "updated_at": d["updated_at"]
        }

def run(input_topic, output_table):
    opts = PipelineOptions(save_main_session=True, streaming=True)
    opts.view_as(StandardOptions).streaming = True
    with beam.Pipeline(options=opts) as p:
        (p
         | beam.io.ReadFromPubSub(topic=input_topic)
         | beam.ParDo(Parse())
         | beam.io.WriteToBigQuery(
                output_table, write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                schema="order_id:INTEGER,customer_id:INTEGER,amount:FLOAT,updated_at:TIMESTAMP"))
