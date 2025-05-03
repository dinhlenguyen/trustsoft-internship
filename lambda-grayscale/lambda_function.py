import boto3
from PIL import Image
import io
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Extract bucket and key
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    target_bucket = os.environ['TARGET_BUCKET']
    target_key = f'grayscale-{source_key}'

    try:
        # Download original image
        response = s3.get_object(Bucket=source_bucket, Key=source_key)
        image_data = response['Body'].read()
        image = Image.open(io.BytesIO(image_data))

        # Convert to black & white (grayscale)
        grayscale = image.convert('L')
        buffer = io.BytesIO()
        grayscale.save(buffer, format='JPEG')
        buffer.seek(0)

        # Upload to destination bucket (public)
        s3.put_object(
            Bucket=target_bucket,
            Key=target_key,
            Body=buffer,
            ContentType='image/jpeg'
        )

        print(f"Saved grayscale image to {target_bucket}/{target_key}")
        return {
            'statusCode': 200,
            'body': f"https://{target_bucket}.s3.amazonaws.com/{target_key}"
        }

    except Exception as e:
        print(f"Error processing image: {e}")
        raise e
