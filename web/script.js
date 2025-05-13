document.addEventListener("DOMContentLoaded", () => {
    const loadProductsBtn = document.getElementById("load-products-btn");
    const addProductForm = document.getElementById("add-product-form");
    const productsContainer = document.getElementById("products-container");
    const loadingIndicator = document.getElementById("loading-indicator");
    const addProductFeedback = document.getElementById("add-product-feedback");
    const categorySelect = document.getElementById("categoryID");

    const API_BASE_URL = "/api"; // Assuming Flask runs on the same domain

    // Function to fetch and populate categories
    async function fetchCategories() {
        try {
            const response = await fetch(`${API_BASE_URL}/categories`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const categories = await response.json();
            categorySelect.innerHTML = 
                '<option value="">Select Category</option>'; // Reset and add default
            categories.forEach(category => {
                const option = document.createElement("option");
                option.value = category.CategoryID;
                option.textContent = category.CategoryName;
                categorySelect.appendChild(option);
            });
        } catch (error) {
            console.error("Error fetching categories:", error);
            // Optionally show an error message to the user
        }
    }

    // Function to display products
    function displayProducts(products) {
        productsContainer.innerHTML = ""; // Clear previous products or placeholder text
        if (products.length === 0) {
            productsContainer.innerHTML = "<p>No products found.</p>";
            return;
        }
        products.forEach(product => {
            const productElement = document.createElement("div");
            productElement.classList.add("post"); // Re-use 'post' class for styling consistency
            productElement.innerHTML = `
                <h3>${product.ProductName} (ID: ${product.ProductID})</h3>
                <p><strong>Description:</strong> ${product.Description || "N/A"}</p>
                <p><strong>Price:</strong> $${product.UnitPrice.toFixed(2)}</p>
                <p><strong>Category:</strong> ${product.CategoryName || (product.CategoryID ? `ID: ${product.CategoryID}` : "N/A")}</p>
                ${product.ImageURL ? `<img src="${product.ImageURL}" alt="${product.ProductName}" style="max-width: 100px; max-height: 100px; display: block; margin-top: 5px;">` : ""}
                <p><small>Added: ${new Date(product.DateAdded).toLocaleString()}</small></p>
                <button class="delete-btn" data-id="${product.ProductID}">Delete Product</button>
            `;
            productsContainer.appendChild(productElement);
        });

        // Add event listeners to new delete buttons
        document.querySelectorAll(".delete-btn").forEach(button => {
            button.addEventListener("click", handleDeleteProduct);
        });
    }

    // Function to fetch products (Read)
    async function fetchProducts() {
        loadingIndicator.style.display = "block";
        productsContainer.innerHTML = ""; // Clear current content
        try {
            const response = await fetch(`${API_BASE_URL}/products`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const products = await response.json();
            displayProducts(products);
        } catch (error) {
            console.error("Error fetching products:", error);
            productsContainer.innerHTML = "<p>Error loading products. Please try again.</p>";
        } finally {
            loadingIndicator.style.display = "none";
        }
    }

    // Function to handle adding a new product (Create)
    async function handleAddProduct(event) {
        event.preventDefault();
        const productName = document.getElementById("productName").value;
        const description = document.getElementById("description").value;
        const unitPrice = parseFloat(document.getElementById("unitPrice").value);
        const categoryID = document.getElementById("categoryID").value;
        const imageURL = document.getElementById("imageURL").value;

        if (!productName || isNaN(unitPrice) || unitPrice <= 0) {
            showFeedback("Product Name and a valid Unit Price are required.", "error");
            return;
        }

        const newProduct = {
            ProductName: productName,
            Description: description,
            UnitPrice: unitPrice,
            CategoryID: categoryID ? parseInt(categoryID) : null,
            ImageURL: imageURL || null
        };

        showFeedback("Adding product...", "info");

        try {
            const response = await fetch(`${API_BASE_URL}/products`, {
                method: "POST",
                body: JSON.stringify(newProduct),
                headers: {
                    "Content-type": "application/json; charset=UTF-8",
                },
            });
            const responseData = await response.json(); // Always try to parse JSON
            if (!response.ok) {
                throw new Error(responseData.message || `HTTP error! status: ${response.status}`);
            }
            showFeedback(`Product added successfully! (ID: ${responseData.ProductID})`, "success");
            addProductForm.reset();
            fetchProducts(); // Refresh list to see the new product
        } catch (error) {
            console.error("Error adding product:", error);
            showFeedback(error.message || "Error adding product. Please try again.", "error");
        }
    }

    // Function to handle deleting a product (Delete)
    async function handleDeleteProduct(event) {
        const productId = event.target.dataset.id;
        if (!confirm(`Are you sure you want to delete product ID ${productId}?`)) {
            return;
        }

        showFeedback(`Deleting product ID ${productId}...`, "info", true);

        try {
            const response = await fetch(`${API_BASE_URL}/products/${productId}`, {
                method: "DELETE",
            });
            const responseData = await response.json(); // Try to parse JSON for messages
            if (!response.ok) {
                throw new Error(responseData.message || `HTTP error! status: ${response.status}`);
            }
            showFeedback(responseData.message || `Product ID ${productId} deleted successfully.`, "success", true);
            event.target.closest(".post").remove();
            if (productsContainer.children.length === 0) {
                 productsContainer.innerHTML = "<p>No products to display. Click \'Load Products\' or add a new one.</p>";
            }
        } catch (error) {
            console.error("Error deleting product:", error);
            showFeedback(error.message || `Error deleting product ID ${productId}. Please try again.`, "error", true);
        }
    }

    // Helper function to show feedback messages
    function showFeedback(message, type, isGlobal = false) {
        const feedbackElement = isGlobal ? loadingIndicator : addProductFeedback;
        if(isGlobal) loadingIndicator.style.display = "block";
        feedbackElement.textContent = message;
        feedbackElement.className = type; // e.g., "success", "error", "info"
        
        if(type === "success" || type === "error"){
            setTimeout(() => {
                feedbackElement.textContent = "";
                feedbackElement.className = "";
                if(isGlobal) loadingIndicator.style.display = "none";
            }, 4000);
        }
    }

    // Event Listeners
    if(loadProductsBtn) loadProductsBtn.addEventListener("click", fetchProducts);
    if(addProductForm) addProductForm.addEventListener("submit", handleAddProduct);

    // Initial actions
    fetchCategories(); // Populate categories dropdown on page load

});

