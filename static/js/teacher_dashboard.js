// Uses ALL_SUBJECTS, which is set as a global in a small inline script
// in teacher_dashboard.html (Flask/Jinja passes the subjects list in as JSON).

const classSelect = document.getElementById("class-select");
const subjectSelect = document.getElementById("subject-select");

classSelect.addEventListener("change", () => {
    const classId = parseInt(classSelect.value);
    subjectSelect.innerHTML = "";

    if (!classId) {
        subjectSelect.disabled = true;
        subjectSelect.innerHTML = '<option value="">Select class first...</option>';
        return;
    }

    const matches = ALL_SUBJECTS.filter(s => s.classId === classId);
    if (matches.length === 0) {
        subjectSelect.innerHTML = '<option value="">No subjects for this class</option>';
        subjectSelect.disabled = true;
        return;
    }

    subjectSelect.disabled = false;
    matches.forEach(s => {
        const opt = document.createElement("option");
        opt.value = s.id;
        opt.textContent = s.name;
        subjectSelect.appendChild(opt);
    });
});
