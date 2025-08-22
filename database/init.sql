-- pgvector දිගුව සක්‍රීය කිරීම
CREATE EXTENSION IF NOT EXISTS vector;

-- නැවුම් ආරම්භයක් සඳහා පවතින වගු ඉවත් කිරීම
DROP TABLE IF EXISTS attendances, leave_balances, leave_requests, employees, departments, hr_policies CASCADE;

-- දෙපාර්තමේන්තු වගුව නිර්මාණය කිරීම
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- සේවක වගුව නිර්මාණය කිරීම
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50),
    department_id INT REFERENCES departments(id),
    phone_number VARCHAR(50),
    address TEXT,
    is_active BOOLEAN DEFAULT true
);

-- පැමිණීමේ දත්ත සඳහා වගුව නිර්මාණය කිරීම
CREATE TABLE attendances (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    attendance_date DATE NOT NULL,
    status VARCHAR(50)
);

-- නිවාඩු ශේෂ වගුව නිර්මාණය කිරීම
CREATE TABLE leave_balances (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    year INT NOT NULL,
    total_days INT NOT NULL,
    days_used INT NOT NULL
);

-- RAG Agent සඳහා HR ප්‍රතිපත්ති වගුව
CREATE TABLE hr_policies (
    id SERIAL PRIMARY KEY,
    document_name VARCHAR(255) NOT NULL,
    chunk_text TEXT NOT NULL,
    embedding VECTOR(1536) -- OpenAI text-embedding-3-small size
);

-- Action Agent සඳහා නිවාඩු ඉල්ලීම් වගුව
CREATE TABLE leave_requests (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    leave_date DATE NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'pending' -- 'pending', 'approved', 'rejected'
);

-- නියැදි දත්ත ඇතුළත් කිරීම

-- දෙපාර්තමේන්තු දත්ත ඇතුළත් කිරීම
INSERT INTO departments (name) VALUES
('IT/Rise AI'),
('Construction'),
('Agriculture'),
('Landscape'),
('Electrical'),
('Mechanical'),
('House Keeping'),
('Architecture'),
('Hr'),
('Qbit'),
('Heavy Machinery'),
('Kitchen'),
('Marketing'),
('GAMES/RamStudios');

-- සේවක දත්ත ඇතුළත් කිරීම (users.json ගොනුවෙන්)
INSERT INTO employees (name, email, role, department_id, phone_number, address, is_active) VALUES
('Yehara', 'yehara@test.com', 'hr', (SELECT id FROM departments WHERE name='IT/Rise AI'), '077-1234567', 'No. 101, Main Street, Colombo 07', true),
('Thavindu', 'Thavindu@test.com', 'leader', (SELECT id FROM departments WHERE name='Construction'), '071-2345678', 'No. 22, Galle Road, Moratuwa', true),
('Kamal', 'Kamal@test.com', 'leader', (SELECT id FROM departments WHERE name='Agriculture'), '076-3456789', 'No. 45, Kandy Road, Kandy', true),
('Kushani', 'Kushani@test.com', 'leader', (SELECT id FROM departments WHERE name='Agriculture'), '075-5678901', 'No. 5, Park Street, Colombo 07', true),
('Gihan', 'Gihan@test.com', 'leader', (SELECT id FROM departments WHERE name='Landscape'), '077-8901234', 'No. 88, Farm Road, Nuwara Eliya', true),
('Nawoda', 'Nawoda@test.com', 'leader', (SELECT id FROM departments WHERE name='Landscape'), '071-9012345', 'No. 4, Industrial Zone, Biyagama', true),
('Chinthaka', 'Chinthaka@test.com', 'leader', (SELECT id FROM departments WHERE name='Construction'), '077-9998888', '123, Test Avenue, Colombo 01', true),
('Nishara', 'Nishara@test.com', 'leader', (SELECT id FROM departments WHERE name='Electrical'), '0765577610', 'No. 21, Temple Road, Colombo', true),
('Vishwa', 'Vishwa@test.com', 'leader', (SELECT id FROM departments WHERE name='Mechanical'), '071 556 7890', 'No. 121, Galle Road, Moratuwa', true),
('Rajitha', 'Rajitha@test.com', 'leader', (SELECT id FROM departments WHERE name='Agriculture'), '078 210 9876', 'No. 3, High Level Road, Jaffna', true),
('Deshan', 'Deshan@test.com', 'leader', (SELECT id FROM departments WHERE name='House Keeping'), '077 458 9212', 'No. 1283, Galle Road, Matara', true),
('Buddika', 'Buddika@test.com', 'leader', (SELECT id FROM departments WHERE name='Mechanical'), '076-3101680', 'No. 24, Flower Mawatha, Colombo', true),
('Ayal', 'Ayal@test.com', 'leader', (SELECT id FROM departments WHERE name='Architecture'), '071-9605023', 'No. 181, Station Lane, Kalmunai', true),
('Simiyon', 'Simiyon@test.com', 'leader', (SELECT id FROM departments WHERE name='Hr'), '070-4843379', 'No. 143, Sea Gardens, Trincomalee', true),
('Venuri', 'Venuri@test.com', 'leader', (SELECT id FROM departments WHERE name='Hr'), '078-2123593', 'No. 148, Sea Road, Anuradhapura', true),
('Rejina', 'Rejina@test.com', 'leader', (SELECT id FROM departments WHERE name='Hr'), '075-1278709', 'No. 66, Main Mawatha, Matale', true),
('Taniya', 'Taniya@test.com', 'leader', (SELECT id FROM departments WHERE name='Qbit'), '077-6195137', 'No. 55, Quarry Road, Kalmunai', true),
('Shehan', 'Shehan@test.com', 'leader', (SELECT id FROM departments WHERE name='Qbit'), '071-4025851', 'No. 22, Hospital Street, Katunayake', true),
('Malika', 'Malika@test.com', 'leader', (SELECT id FROM departments WHERE name='Qbit'), '076-9693555', 'No. 75, Hospital Road, Galle', true),
('Anushka', 'Anushka@test.com', 'leader', (SELECT id FROM departments WHERE name='Qbit'), '077-4762026', 'No. 39, Temple Avenue, Bandarawela', true),
('Raju', 'Raju@test.com', 'leader', (SELECT id FROM departments WHERE name='Heavy Machinery'), '078-4860871', 'No. 10, School Para, Colombo', true),
('Gamini', 'Gamini@test.com', 'leader', (SELECT id FROM departments WHERE name='Kitchen'), '078-7882216', 'No. 178, Main Place, Dambulla', true),
('Wasantha', 'Wasantha@test.com', 'leader', (SELECT id FROM departments WHERE name='Kitchen'), '070-2518620', 'No. 153, Main Place, Wellawatte', true),
('Dhammika', 'Dhammika@test.com', 'leader', (SELECT id FROM departments WHERE name='Construction'), '077-8099322', 'No. 70, Station Avenue, Bandarawela', true),
('Permanent crop leader', 'Permanentcropleader@test.com', 'leader', (SELECT id FROM departments WHERE name='Agriculture'), '078-3839370', 'No. 18, Quarry Avenue, Kandy', true),
('Lakshith Bandara', 'kdasanayakahello9@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '071 556 7890', 'No. 121, Galle Road, Moratuwa', true),
('Malindu Rashmika', 'kdasanayakahello12@gmail.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '078 210 9876', 'No. 3, High Level Road, Jaffna', true),
('Prabath megha', 'kdasanayakahello13@gmail.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '077 765 4321', 'No. 55, Lake Drive, Colombo', true),
('Anjana Rangashan', 'kdasanayakahello@gmail.com', 'employee', (SELECT id FROM departments WHERE name='Marketing'), '071 887 6543', 'No. 45, Main Street, Kandy', true),
('Banula Lavindu', 'edu.tharusha4@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '075 987 6543', 'No. 15, High Level Road, Ratnapura', true),
('Tharinda hasaranga', 'edu.tharusha6@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '072 445 5667', 'No. 72, Hospital Road, Kurunegala', true),
('Pinil Dissanayaka', 'kdasanayakahello8@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '077 123 9876', 'No. 33, Station Road, Galle', true),
('Thisal Thulnith', 'kdasanayakahello10@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '076 890 1234', 'No. 89, Main Street, Colombo', true),
('Ravindu cooray', 'kdasanayakahello2@gmail.com', 'hr', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '076 213 4567', 'No. 210, Temple Road, Colombo', true),
('Hasitha Pathum', 'kdasanayakahello3@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '070 334 5678', 'No. 88, Sea Street, Negombo', true),
('Veenath Mihisara', 'kdasanayakahello7@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '074 889 9001', 'No. 256, Lake Drive, Anuradhapura', true),
('Nipuni Virajitha', 'edu.tharusha@gmail.com', 'employee', (SELECT id FROM departments WHERE name='Marketing'), '075 432 1098', 'No. 178, Sea Street, Matara', true),
('Kolitha Bhanu', 'kdasanayakahello5@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '078 112 2334', 'No. 199, School Lane, Dehiwala', true),
('Kalhara Dasanayaka', 'kdasanayakahello22@gmail.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '077 458 9211', 'No. 128, Galle Road, Matara', true),
('Yasiru Thamsiri', 'yasiru.thamsiri@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '071 234 5678', 'No. 45, Kandy Road, Colombo 07', true),
('Chamidy Ganganath', 'chamidy.ganganath@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '077 345 6789', 'No. 78, Nugegoda Main Road, Nugegoda', true),
('Lahiru Prasanga', 'lahiru.prasanga@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '070 456 7890', 'No. 156, Gampaha Road, Gampaha', true),
('Gihan', 'gihan@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '076 567 8901', 'No. 89, Matara Road, Galle', true),
('Manith Pranawithana', 'manith.pranawithana@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '075 678 9012', 'No. 234, Ratnapura Road, Ratnapura', true),
('Abhisheka Karunarathna', 'abhisheka.karunarathna@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '074 789 0123', 'No. 67, Kurunegala Road, Kurunegala', true),
('Praptha Nimesh', 'praptha.nimesh@company.com', 'employee', (SELECT id FROM departments WHERE name='GAMES/RamStudios'), '073 890 1234', 'No. 123, Badulla Road, Badulla', true),
('Nimthara Thathsarani', 'nimthara.thathsarani@company.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '072 901 2345', 'No. 45, Dehiwala Road, Dehiwala', true),
('Kaveen Deshapriya', 'kaveen.deshapriya@company.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '077 123 4567', 'No. 87, Kalutara Road, Kalutara', true),
('Thisaru Saduthina', 'thisaru.saduthina@company.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '076 234 5678', 'No. 156, Negombo Road, Negombo', true),
('Yomith Rathnayaka', 'yomith.rathnayaka@company.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '075 345 6789', 'No. 234, Anuradhapura Road, Anuradhapura', true),
('Tharuka Karunarathna', 'tharuka.karunarathna@company.com', 'employee', (SELECT id FROM departments WHERE name='IT/Rise AI'), '074 456 7890', 'No. 78, Polonnaruwa Road, Polonnaruwa', true);

-- පැමිණීමේ දත්ත ඇතුළත් කිරීම (attendances.json ගොනුවෙන්)
-- සටහන: මෙය දීර්ඝ ලැයිස්තුවක් බැවින්, මෙහි ඇත්තේ නියැදියක් පමණි.
INSERT INTO attendances (employee_id, attendance_date, status) VALUES
((SELECT id FROM employees WHERE email='Thavindu@test.com'), '2025-08-04', 'Present'),
((SELECT id FROM employees WHERE email='Kamal@test.com'), '2025-08-04', 'Present'),
((SELECT id FROM employees WHERE email='Kushani@test.com'), '2025-08-04', 'Present'),
((SELECT id FROM employees WHERE email='Gihan@test.com'), '2025-08-04', 'Lieu leave'),
((SELECT id FROM employees WHERE email='Nawoda@test.com'), '2025-08-04', 'Present'),
((SELECT id FROM employees WHERE email='Chinthaka@test.com'), '2025-08-04', 'Lieu leave'),
((SELECT id FROM employees WHERE email='Thavindu@test.com'), '2025-08-01', 'Present'),
((SELECT id FROM employees WHERE email='Kamal@test.com'), '2025-08-01', 'Present'),
((SELECT id FROM employees WHERE email='Thavindu@test.com'), '2025-08-02', 'Present'),
((SELECT id FROM employees WHERE email='Thavindu@test.com'), '2025-08-03', 'Present'),
((SELECT id FROM employees WHERE email='kdasanayakahello22@gmail.com'), '2025-08-01', 'Present'),
((SELECT id FROM employees WHERE email='kdasanayakahello22@gmail.com'), '2025-08-02', 'Present'),
((SELECT id FROM employees WHERE email='kdasanayakahello22@gmail.com'), '2025-08-03', 'Present');


-- නියැදි නිවාඩු ශේෂ දත්ත
INSERT INTO leave_balances (employee_id, year, total_days, days_used) VALUES
((SELECT id FROM employees WHERE email='kdasanayakahello22@gmail.com'), 2024, 20, 5),
((SELECT id FROM employees WHERE email='Thavindu@test.com'), 2024, 25, 10),
((SELECT id FROM employees WHERE email='Kamal@test.com'), 2024, 20, 8),
((SELECT id FROM employees WHERE email='Gihan@test.com'), 2024, 22, 4);

-- නියැදි HR ප්‍රතිපත්ති දත්ත
INSERT INTO hr_policies (document_name, chunk_text) VALUES
('Work From Home Policy', 'Employees can work from home up to 2 days per week. A formal request must be submitted to the direct manager at least 48 hours in advance. The company provides a monthly allowance for internet connectivity.'),
('Leave Policy', 'All permanent employees are entitled to 20 days of annual leave per year. Maternity leave is 84 working days, and paternity leave is 5 working days.'),
('Leave Policy', 'Sick leave must be reported to the HR department and the direct manager before 9:00 AM on the day of absence. A medical certificate is required for sick leave of more than 2 consecutive days.');
