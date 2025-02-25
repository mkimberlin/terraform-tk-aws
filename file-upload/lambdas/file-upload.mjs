import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const s3Client = new S3Client({});
const sqsClient = new SQSClient({});
const SQS_QUEUE_URL = process.env.SQS_QUEUE_URL;

export const handler = async (event) => {
  try {
    const bucketName = event.Records[0].s3.bucket.name;
    const objectKey = event.Records[0].s3.object.key;

    const s3GetObjectParams = {
      Bucket: bucketName,
      Key: objectKey,
    };

    const s3Response = await s3Client.send(new GetObjectCommand(s3GetObjectParams));
    const data = await streamToString(s3Response.Body);

    const sqsParams = {
      QueueUrl: SQS_QUEUE_URL,
      MessageBody: data,
    };

    await sqsClient.send(new SendMessageCommand(sqsParams));

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Message sent to SQS" }),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Error processing request", error: error.message }),
    };
  }
};

const streamToString = (stream) =>
  new Promise((resolve, reject) => {
    const chunks = [];
    stream.on("data", (chunk) => chunks.push(chunk));
    stream.on("error", reject);
    stream.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
  });
