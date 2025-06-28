package com.yourcompany.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

import java.io.IOException;

public class TransactionCount {

    // Mapper Class
    public static class TickerMapper extends Mapper<Object, Text, Text, IntWritable> {
        private final static IntWritable one = new IntWritable(1); // Output value is always 1 for counting
        private Text country = new Text(); // Output key will be the country name

        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            String line = value.toString();
            String[] parts = line.split(","); // Assuming CSV is comma-separated

            // Basic validation: Ensure line has enough columns and skip header
            // OnlineRetail.csv typically has 8 columns: InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
            if (parts.length > 7 && !parts[0].equals("InvoiceNo")) {
                String countryStr = parts[7].trim(); // Country is at index 7
                if (!countryStr.isEmpty()) { // Ensure country name is not empty
                    country.set(countryStr);
                    context.write(country, one); // Emit (Country, 1)
                }
            }
        }
    }

    // Reducer Class
    public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        private IntWritable result = new IntWritable(); // Final count for each country

        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            int sum = 0;
            // Sum all the '1's emitted by the mappers for a given country
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result); // Emit (Country, TotalCount)
        }
    }

    // Main Method to configure and run the Job
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        // Parse command line arguments to get input and output paths
        String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
        if (otherArgs.length < 2) {
            System.err.println("Usage: TransactionCount <in> <out>");
            System.exit(2);
        }

        // Create a new Hadoop Job
        Job job = Job.getInstance(conf, "transaction count by country");

        // Set the JAR file that contains the job classes [cite: 12]
        job.setJarByClass(TransactionCount.class);

        // Set Mapper and Reducer classes [cite: 12]
        job.setMapperClass(TickerMapper.class);
        job.setCombinerClass(IntSumReducer.class); // Optional: Use Reducer as Combiner for local aggregation
        job.setReducerClass(IntSumReducer.class);

        // Set output key and value types for the job [cite: 12]
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // Set input and output paths for HDFS [cite: 12]
        FileInputFormat.addInputPath(job, new Path(otherArgs[0])); // Input path (e.g., /user/hadoop/input)
        FileOutputFormat.setOutputPath(job, new Path(otherArgs[1])); // Output path (e.g., /user/hadoop/output_transactions)

        // Submit the job and wait for its completion
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
