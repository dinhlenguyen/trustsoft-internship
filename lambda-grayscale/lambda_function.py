import boto3
from PIL import Image
import pymysql
import io
import os

# Initialize clients
s3 = boto3.client('s3')

# Database connection info from environment variables
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']
TARGET_BUCKET = os.environ['TARGET_BUCKET']

def lambda_handler(event, context):
    try:
        # Get S3 info
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        source_key = event['Records'][0]['s3']['object']['key']
        target_key = f'grayscale-{source_key}'

        # Get image object and metadata
        response = s3.get_object(Bucket=source_bucket, Key=source_key)
        image_data = response['Body'].read()
        metadata = response.get('Metadata', {})
        name = metadata.get('name', '').title()
        surname = metadata.get('surname', '').title()

        # Convert to grayscale
        image = Image.open(io.BytesIO(image_data)).convert('L')
        buffer = io.BytesIO()
        image.save(buffer, format='JPEG')
        buffer.seek(0)

        # Upload grayscale image to target bucket
        s3.put_object(
            Bucket=TARGET_BUCKET,
            Key=target_key,
            Body=buffer,
            ContentType='image/jpeg'
        )

        # Construct URLs
        original_url = f"https://{source_bucket}.s3.amazonaws.com/{source_key}"
        grayscale_url = f"https://{TARGET_BUCKET}.s3.amazonaws.com/{target_key}"

        # Save metadata to RDS
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME
        )
        with connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO uploads (name, surname, original_url, grayscale_url)
                    VALUES (%s, %s, %s, %s)
                """, (name, surname, original_url, grayscale_url))
            connection.commit()

        print(f"✅ Grayscale image saved: {grayscale_url}")
        return {
            'statusCode': 200,
            'body': f"Saved as {grayscale_url}"
        }

    except Exception as e:
        print(f"❌ Error processing image: {e}")
        raise e
