document.addEventListener("DOMContentLoaded", function () {
  // Dropdown functionality
  const dropdowns = document.querySelectorAll(".dropdown");

  // Toggle dropdown on click
  dropdowns.forEach((dropdown) => {
    const toggle = dropdown.querySelector(".dropdown-toggle");
    toggle.addEventListener("click", (e) => {
      e.stopPropagation();

      // Close all other dropdowns
      dropdowns.forEach((otherDropdown) => {
        if (otherDropdown !== dropdown) {
          otherDropdown.classList.remove("active");
        }
      });

      // Toggle current dropdown
      dropdown.classList.toggle("active");
    });
  });

  // Close dropdowns when clicking outside
  document.addEventListener("click", () => {
    dropdowns.forEach((dropdown) => {
      dropdown.classList.remove("active");
    });
  });

  // Prevent dropdown menu clicks from closing the dropdown
  const dropdownMenus = document.querySelectorAll(".dropdown-menu");
  dropdownMenus.forEach((menu) => {
    menu.addEventListener("click", (e) => {
      e.stopPropagation();
    });
  });

  // Search form submission
  const searchForm = document.getElementById("search-form");
  searchForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const searchInput = searchForm.querySelector(".search-input");
    const searchQuery = searchInput.value.trim();

    if (searchQuery) {
      console.log("Searching for:", searchQuery);
      // In a real implementation, this would navigate to search results
      alert(`Searching for: ${searchQuery}`);
    }
  });

  // Make navbar responsive
  function handleResponsive() {
    const width = window.innerWidth;
    const searchContainer = document.querySelector(".search-container");

    if (width < 576) {
      searchContainer.style.maxWidth = "150px";
    } else if (width < 768) {
      searchContainer.style.maxWidth = "200px";
    } else {
      searchContainer.style.maxWidth = "600px";
    }
  }

  // Initial call and resize listener
  handleResponsive();
  window.addEventListener("resize", handleResponsive);
  // FAQ Functionality
  const faqItems = document.querySelectorAll(".faq-item");

  faqItems.forEach((item) => {
    const question = item.querySelector(".faq-question");

    question.addEventListener("click", () => {
      // Close all other FAQ items
      faqItems.forEach((otherItem) => {
        if (otherItem !== item) {
          otherItem.classList.remove("active");
        }
      });

      // Toggle current FAQ item
      item.classList.toggle("active");
    });
  });
});
