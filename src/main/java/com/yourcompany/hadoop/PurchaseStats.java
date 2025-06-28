package com.yourcompany.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

import java.io.IOException;

public class PurchaseStats {

    // Mapper Class
    public static class StatsMapper extends Mapper<Object, Text, Text, DoubleWritable> {
        private Text country = new Text();
        private DoubleWritable unitPrice = new DoubleWritable();

        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            String line = value.toString();
            String[] parts = line.split(","); // Assuming CSV is comma-separated

            if (parts.length > 7 && !parts[0].equals("InvoiceNo")) { // Skip header and validate columns
                try {
                    String countryStr = parts[7].trim(); // Country is at index 7
                    // UnitPrice is at index 5. Handle potential parsing errors and empty strings.
                    double price = Double.parseDouble(parts[5].trim());

                    if (!countryStr.isEmpty() && price >= 0) { // Ensure valid country and positive price
                        country.set(countryStr);
                        unitPrice.set(price);
                        context.write(country, unitPrice); // Emit (Country, UnitPrice)
                    }
                } catch (NumberFormatException e) {
                    // Log or ignore lines with invalid UnitPrice
                    System.err.println("Skipping malformed line (invalid UnitPrice): " + line);
                }
            }
        }
    }

    // Reducer Class
    public static class StatsReducer extends Reducer<Text, DoubleWritable, Text, Text> {
        private Text result = new Text();

        public void reduce(Text key, Iterable<DoubleWritable> values, Context context) throws IOException, InterruptedException {
            double sum = 0;
            int count = 0;
            double min = Double.MAX_VALUE; // Initialize min to a very large value
            double max = Double.MIN_VALUE; // Initialize max to a very small value

            for (DoubleWritable val : values) {
                double price = val.get();
                sum += price;
                count++;
                if (price < min) {
                    min = price;
                }
                if (price > max) {
                    max = price;
                }
            }

            double average = count > 0 ? sum / count : 0; // Avoid division by zero

            // Format the output string for Min, Max, Avg
            result.set(String.format("Min: %.2f, Max: %.2f, Avg: %.2f", min, max, average));
            context.write(key, result); // Emit (Country, "Min: X, Max: Y, Avg: Z")
        }
    }

    // Main Method to configure and run the Job
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
        if (otherArgs.length < 2) {
            System.err.println("Usage: PurchaseStats <in> <out>");
            System.exit(2);
        }
        Job job = Job.getInstance(conf, "purchase statistics by country");
        job.setJarByClass(PurchaseStats.class);
        job.setMapperClass(StatsMapper.class);
        // No Combiner for min/max/avg calculation, as it can lead to incorrect results
        job.setReducerClass(StatsReducer.class);

        job.setMapOutputKeyClass(Text.class); // Mapper's output key type
        job.setMapOutputValueClass(DoubleWritable.class); // Mapper's output value type

        job.setOutputKeyClass(Text.class); // Reducer's final output key type
        job.setOutputValueClass(Text.class); // Reducer's final output value type (the formatted string)

        FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
        FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
