            const roleSelect = document.getElementById("role-select");
            const classField = document.getElementById("class-field");
            roleSelect.addEventListener("change", () => {
                classField.style.display = roleSelect.value === "student" ? "inline" : "none";
            });
        
