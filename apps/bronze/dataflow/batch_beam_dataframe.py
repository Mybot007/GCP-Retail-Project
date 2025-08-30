import argparse, apache_beam as beam
from apache_beam.dataframe.convert import to_dataframe
from apache_beam.options.pipeline_options import PipelineOptions

def run(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)     # gs://bucket/path/*.csv
    ap.add_argument("--output_table", required=True)  # project:dataset.table
    opts, _ = ap.parse_known_args(argv)
    popts = PipelineOptions(save_main_session=True, streaming=False)

    with beam.Pipeline(options=popts) as p:
        rows = (p
          | "ReadCSV" >> beam.io.ReadFromText(opts.input, skip_header_lines=1)
          | "Parse" >> beam.Map(lambda line: line.split(",")))
        # Convert to dataframe for light transforms
        df = to_dataframe(rows).rename(columns={0:"order_id",1:"customer_id",2:"amount",3:"updated_at"})
        # (minimal transforms here)
        _ = (df.to_pcollection()
             | "ToBQ" >> beam.io.WriteToBigQuery(
                    opts.output_table, write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                    create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                    schema="order_id:INTEGER,customer_id:INTEGER,amount:FLOAT,updated_at:TIMESTAMP"))

if __name__ == "__main__":
    run()
