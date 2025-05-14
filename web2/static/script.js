document.addEventListener("DOMContentLoaded", () => {
    const loadProductsBtn = document.getElementById("load-products-btn");
    const productsContainer = document.getElementById("products-container");
    const categoryDropdown = document.getElementById("categoryID");
    const addProductForm = document.getElementById("add-product-form");
    const addProductFeedback = document.getElementById("add-product-feedback");
    const loadingIndicator = document.getElementById("loading-indicator");

    // Function to render products
    const renderProducts = (products) => {
        if (products.length === 0) {
            productsContainer.innerHTML = "<p>No products found. Click 'Load Products' or add a new one.</p>";
            return;
        }
        productsContainer.innerHTML = products.map(product => `
            <div class="product" id="product-${product.ProductID}">
                <h3>${product.ProductName}</h3>
                <p>${product.Description || "No description available."}</p>
                <p>Price: $${product.UnitPrice}</p>
                <p>Category: ${product.CategoryName || "Uncategorized"}</p>
                <img src="${product.ImageURL || "https://via.placeholder.com/150"}" alt="${product.ProductName}" />
                <button class="delete-product-btn" data-product-id="${product.ProductID}">Delete Product</button>
            </div>
        `).join("");
    };

    // Function to fetch and load products
    const fetchAndLoadProducts = async () => {
        loadingIndicator.style.display = "block";
        try {
            const response = await fetch("/api/products");
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const products = await response.json();
            renderProducts(products);
        } catch (error) {
            console.error("Error loading products:", error);
            productsContainer.innerHTML = `<p class="error">Failed to load products. Please try again later. Details: ${error.message}</p>`;
        } finally {
            loadingIndicator.style.display = "none";
        }
    };

    // Load Products Button Event Listener
    loadProductsBtn.addEventListener("click", fetchAndLoadProducts);

    // Load Categories for Product Form
    const loadCategories = async () => {
        try {
            const response = await fetch("/api/categories");
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const categories = await response.json();
            categoryDropdown.innerHTML = "<option value=\"\">Select Category</option>"; // Add a default option
            categories.forEach(category => {
                categoryDropdown.innerHTML += `<option value="${category.CategoryID}">${category.CategoryName}</option>`;
            });
        } catch (error) {
            console.error("Error loading categories:", error);
            categoryDropdown.innerHTML = "<option value=\"\">Error loading categories</option>";
        }
    };
    loadCategories();

    // Add New Product Form Event Listener
    addProductForm.addEventListener("submit", async (e) => {
        e.preventDefault();
        addProductFeedback.textContent = "";
        addProductFeedback.className = "";
        const formData = new FormData(addProductForm);
        const data = Object.fromEntries(formData.entries());

        if (!data.productName || !data.unitPrice || !data.categoryID) {
            addProductFeedback.textContent = "Product Name, Unit Price, and Category are required.";
            addProductFeedback.classList.add("error");
            return;
        }

        try {
            const response = await fetch("/api/products", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(data)
            });
            const result = await response.json();
            if (response.ok) {
                addProductFeedback.textContent = "Product added successfully!";
                addProductFeedback.classList.add("success");
                addProductForm.reset();
                fetchAndLoadProducts(); // Refresh product list
            } else {
                addProductFeedback.textContent = result.error || "Failed to add product.";
                addProductFeedback.classList.add("error");
            }
        } catch (error) {
            console.error("Error adding product:", error);
            addProductFeedback.textContent = "Failed to add product. Please try again later.";
            addProductFeedback.classList.add("error");
        }
    });

    // Event delegation for delete buttons
    productsContainer.addEventListener("click", async (e) => {
        if (e.target.classList.contains("delete-product-btn")) {
            const productId = e.target.dataset.productId;
            if (confirm(`Are you sure you want to delete product ID ${productId}?`)) {
                try {
                    const response = await fetch(`/api/products/${productId}`, {
                        method: "DELETE"
                    });
                    const result = await response.json(); // Expecting a JSON response
                    if (response.ok) {
                        alert(result.message || "Product deleted successfully!");
                        fetchAndLoadProducts(); // Refresh product list
                    } else {
                        alert(`Failed to delete product: ${result.error || "Unknown error"}`);
                    }
                } catch (error) {
                    console.error("Error deleting product:", error);
                    alert("Failed to delete product. Please try again later.");
                }
            }
        }
    });

    // Initial load of products
    fetchAndLoadProducts();
});

