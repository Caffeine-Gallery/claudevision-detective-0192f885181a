import { backend } from 'declarations/backend';

document.getElementById('detectButton').addEventListener('click', async () => {
  const apiKey = document.getElementById('apiKey').value;
  const imageInput = document.getElementById('imageInput');
  const resultDiv = document.getElementById('result');

  if (imageInput.files.length > 0) {
    const file = imageInput.files[0];
    const reader = new FileReader();

    reader.onload = async function(event) {
      const base64Image = event.target.result.split(',')[1];
      
      try {
        const result = await backend.detectObjects(apiKey, base64Image);
        if (result.ok) {
          try {
            const parsedResult = JSON.parse(result.ok);
            resultDiv.textContent = JSON.stringify(parsedResult, null, 2);
          } catch (parseError) {
            console.error('Error parsing JSON:', parseError);
            resultDiv.textContent = 'Error: Invalid JSON response from server';
          }
        } else {
          console.error('Error from backend:', result.err);
          resultDiv.textContent = `Error: ${result.err}`;
        }
      } catch (error) {
        console.error('Error calling backend:', error);
        resultDiv.textContent = `Error: ${error.message}`;
      }
    };

    reader.readAsDataURL(file);
  } else {
    resultDiv.textContent = 'Please select an image first.';
  }
});
