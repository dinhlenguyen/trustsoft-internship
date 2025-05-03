// Configure the AWS SDK
AWS.config.region = 'eu-west-1';
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'eu-west-1:2269dd15-2140-4471-9921-52ae3c797468'
});

// Create an S3 client
const s3 = new AWS.S3();

document.getElementById('upload-form').addEventListener('submit', (event) => {
    event.preventDefault();

    const fileInput = document.getElementById('file-input');
    const file = fileInput.files[0];
    if (!file) {
        alert('Please select a file to upload.');
        return;
    }

    const key = `${file.name}`;
    const params = {
        Bucket: 's3-upload-form-internship-dinh',
        Key: key,
        Body: file
    };

    s3.putObject(params, (err, data) => {
        if (err) {
            console.error('Error uploading file:', err);
            alert('An error occurred while uploading the file.');
        } else {
            console.log('File uploaded successfully:', data);
            alert('File uploaded successfully!');
        }
    });
});