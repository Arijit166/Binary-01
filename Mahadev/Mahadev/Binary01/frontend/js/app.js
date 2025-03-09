async function connectMetaMask(role) {
    if (window.ethereum) {
        try {
            const accounts = await ethereum.request({ method: 'eth_requestAccounts' });

            if (accounts.length > 0) {
                const userAddress = accounts[0]; // Get first account
                console.log("Connected MetaMask Account:", userAddress);

                // Store in sessionStorage (deleted when browser closes)
                sessionStorage.setItem("metaMaskAccount", userAddress);

                // Define the correct path
                const redirectURL = role === "creator" 
                    ? "/Mahadev/Binary01/frontend/creators.html" 
                    : "/Mahadev/Binary01/frontend/learners.html";

                // Redirect only if MetaMask is connected
                window.location.href = redirectURL;
            } else {
                alert("MetaMask connection failed. No account detected.");
            }
        } catch (error) {
            console.error("MetaMask connection error:", error);
            alert("Failed to connect with MetaMask.");
        }
    } else {
        alert("MetaMask is not installed. Please install it to continue.");
    }
}

// Event listeners
document.getElementById("Button1").addEventListener("click", () => connectMetaMask("creator"));
document.getElementById("Button2").addEventListener("click", () => connectMetaMask("learner"));