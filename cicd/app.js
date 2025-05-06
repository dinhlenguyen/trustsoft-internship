// Configure the AWS SDK
AWS.config.region = 'eu-west-1';
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'eu-west-1:5ac4a2c6-3e25-4905-820a-af2895d7a726'
});

// Create an S3 client
const s3 = new AWS.S3();

document.getElementById('upload-form').addEventListener('submit', (event) => {
    event.preventDefault();

    const fileInput = document.getElementById('file-input');
    const file = fileInput.files[0];
    const name = document.getElementById('name-input').value.trim();
    const surname = document.getElementById('surname-input').value.trim();

    if (!file || !name || !surname) {
        alert('Please fill in all fields and select a file.');
        return;
    }

    const key = `${file.name}`;
    const params = {
        Bucket: 's3-upload-form-internship-dinh',
        Key: key,
        Body: file,
        Metadata: {
            name: name.toLowerCase(),
            surname: surname.toLowerCase()
        }
    };

    s3.putObject(params, (err, data) => {
        const resultDiv = document.getElementById('result');

        if (err) {
            console.error('Error uploading file:', err);
            alert('An error occurred while uploading the file.');
            return;
        }

        console.log('File uploaded successfully:', data);
        alert('File uploaded successfully! Processing...');

        const grayscaleKey = `grayscale-${file.name}`;
        const imageUrl = `https://s3-lambda-internship-dinh.s3.amazonaws.com/${grayscaleKey}`;

        resultDiv.innerHTML = '<p class="text-muted">Waiting for image to be processed...</p>';

        // Wait before trying to load the image
        setTimeout(() => {
            const img = document.createElement('img');
            img.src = imageUrl;
            img.alt = 'Grayscale image';
            img.classList.add('img-fluid', 'rounded', 'shadow');
            img.style.maxWidth = '300px';

            img.onload = () => {
                resultDiv.innerHTML = '';
                resultDiv.appendChild(img);
            };

            img.onerror = () => {
                resultDiv.innerHTML = '<p class="text-danger">Image is still processing or failed to load. Please try again shortly.</p>';
            };
        }, 2500);
    });
});
