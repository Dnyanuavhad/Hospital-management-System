<%@ page import="java.sql.*" %>
<%
    // Database connection settings
    String url = "jdbc:mysql://localhost:3306/hospital_management_system";
    String user = "root";   // your MySQL username
    String pass = "";       // your MySQL password

    Connection con = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, pass);
        st = con.createStatement();

        // Auto-create tables
        st.execute("CREATE TABLE IF NOT EXISTS patients (" +
                   "id INT AUTO_INCREMENT PRIMARY KEY," +
                   "name VARCHAR(100)," +
                   "age INT," +
                   "gender VARCHAR(10)," +
                   "disease VARCHAR(200))");

        st.execute("CREATE TABLE IF NOT EXISTS doctors (" +
                   "id INT AUTO_INCREMENT PRIMARY KEY," +
                   "name VARCHAR(100)," +
                   "specialization VARCHAR(100))");

        st.execute("CREATE TABLE IF NOT EXISTS appointments (" +
                   "id INT AUTO_INCREMENT PRIMARY KEY," +
                   "patient_id INT," +
                   "doctor_id INT," +
                   "date DATE," +
                   "FOREIGN KEY (patient_id) REFERENCES patients(id)," +
                   "FOREIGN KEY (doctor_id) REFERENCES doctors(id))");

        // Handle actions
        String action = request.getParameter("action");

        if ("addPatient".equals(action)) {
            String name = request.getParameter("name");
            int age = Integer.parseInt(request.getParameter("age"));
            String gender = request.getParameter("gender");
            String disease = request.getParameter("disease");
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO patients(name, age, gender, disease) VALUES(?,?,?,?)");
            ps.setString(1, name);
            ps.setInt(2, age);
            ps.setString(3, gender);
            ps.setString(4, disease);
            ps.executeUpdate();
            out.println("<p class='success'>Patient Added Successfully!</p>");
        }

        if ("addDoctor".equals(action)) {
            String name = request.getParameter("name");
            String specialization = request.getParameter("specialization");
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO doctors(name, specialization) VALUES(?,?)");
            ps.setString(1, name);
            ps.setString(2, specialization);
            ps.executeUpdate();
            out.println("<p class='success'>Doctor Added Successfully!</p>");
        }

        if ("addAppointment".equals(action)) {
            int pid = Integer.parseInt(request.getParameter("patient_id"));
            int did = Integer.parseInt(request.getParameter("doctor_id"));
            String date = request.getParameter("date");
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO appointments(patients_id, doctor_id, date) VALUES(?,?,?)");
            ps.setInt(1, pid);
            ps.setInt(2, did);
            ps.setString(3, date);
            ps.executeUpdate();
            out.println("<p class='success'>Appointment Scheduled Successfully!</p>");
        }

    } catch(Exception e) {
        out.println("<p class='error'>Error: "+ e.getMessage() +"</p>");
    }
%>

<html>
<head>
    <title>Hospital Management System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f8fb;
            margin: 20px;
            color: #333;
        }
        h1 {
            text-align: center;
            color: #0066cc;
        }
        h2 {
            color: #444;
            margin-top: 30px;
        }
        form {
            background: #fff;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0px 2px 5px rgba(0,0,0,0.1);
            width: 350px;
        }
        input[type="text"], input[type="submit"] {
            padding: 8px;
            margin: 5px 0;
            width: 95%;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        input[type="submit"] {
            background: #0066cc;
            color: white;
            border: none;
            cursor: pointer;
            font-weight: bold;
        }
        input[type="submit"]:hover {
            background: #004999;
        }
        .section {
            margin-bottom: 40px;
        }
        .list {
            background: #fff;
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0px 2px 5px rgba(0,0,0,0.1);
        }
        .success {
            color: green;
            font-weight: bold;
        }
        .error {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>Hospital Management System</h1>

    <!-- Add Patient -->
    <div class="section">
        <h2>Add Patient</h2>
        <form method="post">
            <input type="hidden" name="action" value="addPatient"/>
            <input type="text" name="name" placeholder="Name"/><br/>
            <input type="text" name="age" placeholder="Age"/><br/>
            <input type="text" name="gender" placeholder="Gender"/><br/>
            <input type="text" name="disease" placeholder="Disease"/><br/>
            <input type="submit" value="Add Patient"/>
        </form>

        <div class="list">
            <h3>Patients List</h3>
            <%
                rs = st.executeQuery("SELECT * FROM patients");
                while(rs.next()){
                    out.println("ID: "+rs.getInt("id")+
                                " | Name: "+rs.getString("name")+
                                " | Age: "+rs.getInt("age")+
                                " | Gender: "+rs.getString("gender")+
                                " | Disease: "+rs.getString("disease")+"<br/>");
                }
            %>
        </div>
    </div>

    <!-- Add Doctor -->
    <div class="section">
        <h2>Add Doctor</h2>
        <form method="post">
            <input type="hidden" name="action" value="addDoctor"/>
            <input type="text" name="name" placeholder="Name"/><br/>
            <input type="text" name="specialization" placeholder="Specialization"/><br/>
            <input type="submit" value="Add Doctor"/>
        </form>

        <div class="list">
            <h3>Doctors List</h3>
            <%
                rs = st.executeQuery("SELECT * FROM doctors");
                while(rs.next()){
                    out.println("ID: "+rs.getInt("id")+
                                " | Name: "+rs.getString("name")+
                                " | Specialization: "+rs.getString("specialization")+"<br/>");
                }
            %>
        </div>
    </div>

    <!-- Schedule Appointment -->
    <div class="section">
        <h2>Schedule Appointment</h2>
        <form method="post">
            <input type="hidden" name="action" value="addAppointment"/>
            <input type="text" name="patient_id" placeholder="Patient ID"/><br/>
            <input type="text" name="doctor_id" placeholder="Doctor ID"/><br/>
            <input type="text" name="date" placeholder="YYYY-MM-DD"/><br/>
            <input type="submit" value="Schedule Appointment"/>
        </form>

        <div class="list">
            <h3>Appointments List</h3>
            <%
                rs = st.executeQuery("SELECT a.id, p.name AS patient, d.name AS doctor, a.date " +
                                     "FROM appointments a " +
                                     "JOIN patients p ON a.patient_id=p.id " +
                                     "JOIN doctors d ON a.doctor_id=d.id");
                while(rs.next()){
                    out.println("Appt ID: "+rs.getInt("id")+
                                " | Patients: "+rs.getString("patients")+
                                " | Doctor: "+rs.getString("doctor")+
                                " | Date: "+rs.getDate("date")+"<br/>");
                }
            %>
        </div>
    </div>
</body>
</html>