<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.manjare.DBConnection" %>

<%
    String editId = request.getParameter("edit");

    boolean editMode = false;
    boolean editLoadError = false;

    int editDriverId = 0;

    String editName = "";
    String editMobile = "";
    String editLicenseNo = "";
    String editStatus = "Present";
    Integer editVehicleId = null;

    if (editId != null && editId.matches("\\d+")) {
        try {
            editDriverId = Integer.parseInt(editId);

            String editSql = "SELECT driver_id, name, mobile, "
                    + "license_no, status, vehicle_id "
                    + "FROM drivers WHERE driver_id = ?";

            try (Connection editCon = DBConnection.getConnection();
                 PreparedStatement editPs = editCon.prepareStatement(editSql)) {

                editPs.setInt(1, editDriverId);

                try (ResultSet editRs = editPs.executeQuery()) {
                    if (editRs.next()) {
                        editMode = true;
                        editName = editRs.getString("name") == null
                                ? "" : editRs.getString("name");
                        editMobile = editRs.getString("mobile") == null
                                ? "" : editRs.getString("mobile");
                        editLicenseNo = editRs.getString("license_no") == null
                                ? "" : editRs.getString("license_no");
                        editStatus = editRs.getString("status") == null
                                ? "Present" : editRs.getString("status");

                        int vehicleValue = editRs.getInt("vehicle_id");
                        if (!editRs.wasNull()) {
                            editVehicleId = vehicleValue;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            editLoadError = true;
        }
    }
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Drivers | Manjare Tours & Travels
    </title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background:
                linear-gradient(
                    rgba(7, 25, 43, 0.35),
                    rgba(7, 25, 43, 0.50)
                ),
                url("images/dashboard-bg.png");
                background-size: cover;
                background-position: center top;
                background-attachment: fixed;
                background-repeat: no-repeat;
                color: white;
                min-height: 100vh;
        }

        .navbar {
            height: 80px;
            background: #0b2239;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 40px;
            border-bottom: 1px solid rgba(255,255,255,0.15);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .nav-left {
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .menu-btn {
            width: 42px;
            height: 42px;
            border: none;
            background: transparent;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 6px;
            padding: 8px;
        }


        .menu-btn span {
            display: block;
            width: 25px;
            height: 3px;
            background: white;
            border-radius: 3px;
            transition: 0.3s;
        }


        .menu-btn:hover span {
            background: #f4b942;
        }

        .logo {
            font-size: 24px;
            font-weight: bold;
            letter-spacing: 3px;
        }

        .logo span {
            display: block;
            font-size: 11px;
            color: #f4b942;
            letter-spacing: 4px;
            margin-top: 4px;
        }

        .back {
            color: white;
            border: 1px solid #d4af37;
            padding: 10px 18px;
            text-decoration: none;
            border-radius: 6px;
        }
        .sidebar {
            position: fixed;
            top: 0;
            left: -300px;
            width: 290px;
            height: 100vh;
            background: rgba(11, 34, 57, 0.82);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
            z-index: 2000;
            padding: 25px 20px;
            box-shadow: 5px 0 20px rgba(0,0,0,0.35);
            transition: left 0.35s ease;
        }

        .sidebar.active {
            left: 0;
        }

        .sidebar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255,255,255,0.12);
            margin-bottom: 20px;
        }

        .sidebar-title {
            font-size: 21px;
            font-weight: bold;
        }

        .sidebar-title span {
            display: block;
            color: #f4b942;
            font-size: 10px;
            letter-spacing: 3px;
            margin-top: 4px;
        }

        .close-btn {
            background: transparent;
            border: none;
            color: white;
            font-size: 28px;
            cursor: pointer;
        }

        .close-btn:hover {
            color: #f4b942;
        }

        .sidebar-menu {
            list-style: none;
        }

        .sidebar-menu li {
            margin-bottom: 8px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 14px;
            text-decoration: none;
            color: rgba(255,255,255,0.85);
            padding: 13px 15px;
            border-radius: 8px;
            font-size: 15px;
            transition: 0.25s;
        }

        .sidebar-menu a:hover {
            background: rgba(244,185,66,0.12);
            color: #f4b942;
            transform: translateX(4px);
        }

        .sidebar-icon {
            font-size: 20px;
            width: 25px;
            text-align: center;
        }

        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.55);
            z-index: 1500;
            opacity: 0;
            visibility: hidden;
            transition: 0.3s;
        }

        .overlay.active {
            opacity: 1;
            visibility: visible;
        }

        .container {
            max-width: 1400px;
            margin: auto;
            padding: 35px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 25px;
        }

        button {
            background: #d4af37;
            border: none;
            padding: 12px 20px;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
        }

        .form {
            display: none;
            background: #0b2239;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }

        .form h2 {
            color: #d4af37;
            margin-bottom: 20px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2,1fr);
            gap: 18px;
        }

        label {
            display: block;
            margin-bottom: 7px;
        }

        input,
        select {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 5px;
        }

        .save {
            margin-top: 20px;
        }

        .cancel-button {
            display: inline-block;
            margin-top: 20px;
            margin-left: 10px;
            padding: 12px 20px;
            border: 1px solid #d4af37;
            border-radius: 6px;
            color: white;
            text-decoration: none;
            font-weight: bold;
        }

        .cancel-button:hover {
            background: rgba(212, 175, 55, 0.12);
        }

        .actions {
            white-space: nowrap;
        }

        .actions a,
        .actions button {
            display: inline-block;
            margin: 2px 5px 2px 0;
            padding: 8px 11px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 13px;
            font-weight: bold;
        }

        .actions .edit {
            background: #d4af37;
            color: #07192b;
        }

        .actions .delete {
            background: #b93636;
            color: white;
        }

        .actions .delete:hover {
            background: #982828;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: #0b2239;
        }

        th {
            background: #102f4d;
            color: #d4af37;
            padding: 15px;
            text-align: left;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid rgba(255,255,255,.08);
        }

        .message {
            background: #163b55;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
        }

    </style>

</head>

<body>
<!-- =========================
     SIDEBAR
========================== -->

<div class="sidebar" id="sidebar">

    <div class="sidebar-header">

        <div class="sidebar-title">

            MANJARE

            <span>TOURS & TRAVELS</span>

        </div>


        <button class="close-btn"
                onclick="closeSidebar()">

            ×

        </button>

    </div>


    <ul class="sidebar-menu">

        <li>
            <a href="dashboard.jsp">
                <span class="sidebar-icon">🏠</span>
                Dashboard
            </a>
        </li>


        <li>
            <a href="vehicles.jsp">
                <span class="sidebar-icon">🚗</span>
                Vehicles
            </a>
        </li>


        <li>
            <a href="drivers.jsp">
                <span class="sidebar-icon">👨‍✈️</span>
                Drivers
            </a>
        </li>


        <li>
            <a href="customers.jsp">
                <span class="sidebar-icon">🧳</span>
                Customers
            </a>
        </li>


        <li>
            <a href="trips.jsp">
                <span class="sidebar-icon">🛣️</span>
                Trips
            </a>
        </li>


        <li>
            <a href="expenses.jsp">
                <span class="sidebar-icon">💰</span>
                Expenses
            </a>
        </li>


        <li>
            <a href="payments.jsp">
                <span class="sidebar-icon">💳</span>
                Payments
            </a>
        </li>


        <li>
            <a href="reports.jsp">
                <span class="sidebar-icon">📊</span>
                Reports
            </a>
        </li>

        <li>
                <a href="maintenance.jsp">
                    <span class="sidebar-icon">🔧</span>
                    Vehicle Maintenance
                </a>
            </li>

    </ul>

</div>


<!-- SIDEBAR OVERLAY -->

<div class="overlay"
     id="overlay"
     onclick="closeSidebar()">
</div>

<div class="navbar">

    <div class="nav-left">

        <!-- HAMBURGER -->

        <button class="menu-btn"
                onclick="openSidebar()">

            <span></span>
            <span></span>
            <span></span>

        </button>


        <!-- LOGO -->

        <div class="logo">

            MANJARE

            <span>
                TOURS & TRAVELS
            </span>

        </div>

    </div>

    <a href="dashboard.jsp"
       class="back">

        ← Dashboard

    </a>

</div>


<div class="container">

    <div class="header">

        <h1>
            👨‍✈️ Drivers
        </h1>

        <button onclick="showForm()">
            + Add Driver
        </button>

    </div>


    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");

        if ("added".equals(success)) {
    %>
        <div class="message">Driver added successfully.</div>
    <%
        } else if ("updated".equals(success)) {
    %>
        <div class="message">Driver updated successfully.</div>
    <%
        } else if ("deleted".equals(success)) {
    %>
        <div class="message">Driver deleted successfully.</div>
    <%
        }

        if ("database".equals(error)) {
    %>
        <div class="message">Database operation failed. Check the Tomcat console and database constraints.</div>
    <%
        } else if ("inuse".equals(error)) {
    %>
        <div class="message">This driver is assigned to an existing trip and cannot be deleted.</div>
    <%
        } else if ("invalidid".equals(error)) {
    %>
        <div class="message">Invalid driver ID.</div>
    <%
        } else if ("notfound".equals(error)) {
    %>
        <div class="message">The requested driver was not found.</div>
    <%
        } else if ("invalidaction".equals(error)) {
    %>
        <div class="message">Invalid action requested.</div>
    <%
        }

        if (editLoadError) {
    %>
        <div class="message">Unable to load driver details. Check the database connection.</div>
    <%
        } else if (editId != null && !editMode && !editLoadError) {
    %>
        <div class="message">The requested driver could not be found.</div>
    <%
        }
    %>


    <div class="form"
         id="driverForm"
         style="<%= (editMode || editLoadError || (editId != null && !editMode)) ? "display:block;" : "display:none;" %>">

        <h2>
            <%= editMode ? "Edit Driver" : "Add Driver" %>
        </h2>

        <form
            action="<%= request.getContextPath() %>/DriverServlet"
            method="post">

            <input type="hidden" name="action"
                   value="<%= editMode ? "update" : "add" %>">

            <% if (editMode) { %>
                <input type="hidden" name="driverId"
                       value="<%= editDriverId %>">
            <% } %>

            <div class="grid">

                <div>

                    <label>
                        Driver Name
                    </label>

                    <input
                        type="text"
                        name="name"
                        value="<%= editMode ? editName : "" %>"
                        required>

                </div>


                <div>

                    <label>
                        Mobile
                    </label>

                    <input
                        type="text"
                        name="mobile"
                        value="<%= editMode ? editMobile : "" %>">

                </div>


                <div>

                    <label>
                        License Number
                    </label>

                    <input
                        type="text"
                        name="licenseNo"
                        value="<%= editMode ? editLicenseNo : "" %>">

                </div>


                <div>

                    <label>
                        Status
                    </label>

                    <select name="status">

                        <option value="Present"
                            <%= "Present".equals(editStatus) ? "selected" : "" %>>
                            Present
                        </option>

                        <option value="On Trip"
                            <%= "On Trip".equals(editStatus) ? "selected" : "" %>>
                            On Trip
                        </option>

                        <option value="Leave"
                            <%= "Leave".equals(editStatus) ? "selected" : "" %>>
                            Leave
                        </option>

                    </select>

                </div>


                <div>

                    <label>
                        Vehicle
                    </label>

                    <select name="vehicleId">

                        <option value=""
                            <%= editVehicleId == null ? "selected" : "" %>>
                            No Vehicle
                        </option>

                        <%

                            try {

                                Connection con =
                                    DBConnection.getConnection();

                                PreparedStatement ps =
                                    con.prepareStatement(
                                        "SELECT vehicle_id, vehicle_number, model " +
                                        "FROM vehicles " +
                                        "ORDER BY vehicle_id DESC"
                                    );

                                ResultSet rs =
                                    ps.executeQuery();

                                while(rs.next()) {

                        %>

                        <option value="<%= rs.getInt("vehicle_id") %>"
                            <%= editVehicleId != null
                                && editVehicleId.intValue() == rs.getInt("vehicle_id")
                                ? "selected" : "" %>>

                            <%= rs.getString("vehicle_number") %>
                            -
                            <%= rs.getString("model") %>

                        </option>

                        <%

                                }

                                rs.close();
                                ps.close();
                                con.close();

                            } catch(Exception e) {

                                out.print(
                                    "<option>Unable to load vehicles</option>"
                                );

                            }

                        %>

                    </select>

                </div>

            </div>


            <button
                type="submit"
                class="save">
                <%= editMode ? "Update Driver" : "Save Driver" %>
            </button>

            <% if (editMode) { %>
                <a href="drivers.jsp" class="cancel-button">Cancel</a>
            <% } %>

        </form>

    </div>


    <table>

        <tr>

            <th>ID</th>
            <th>Name</th>
            <th>Mobile</th>
            <th>License</th>
            <th>Status</th>
            <th>Vehicle</th>
            <th>Actions</th>

        </tr>


        <%

            try {

                Connection con =
                    DBConnection.getConnection();

                String sql =
                    "SELECT d.driver_id, d.name, " +
                    "d.mobile, d.license_no, d.status, " +
                    "v.vehicle_number " +
                    "FROM drivers d " +
                    "LEFT JOIN vehicles v " +
                    "ON d.vehicle_id = v.vehicle_id " +
                    "ORDER BY d.driver_id DESC";

                PreparedStatement ps =
                    con.prepareStatement(sql);

                ResultSet rs =
                    ps.executeQuery();

                while(rs.next()) {

        %>

        <tr>

            <td>
                <%= rs.getInt("driver_id") %>
            </td>

            <td>
                <%= rs.getString("name") %>
            </td>

            <td>
                <%= rs.getString("mobile") %>
            </td>

            <td>
                <%= rs.getString("license_no") %>
            </td>

            <td>
                <%= rs.getString("status") %>
            </td>

            <td>
                <%= rs.getString("vehicle_number") == null
                    ? "Not Assigned"
                    : rs.getString("vehicle_number") %>
            </td>

            <td class="actions">
                <a class="edit"
                   href="drivers.jsp?edit=<%= rs.getInt("driver_id") %>">
                    Edit
                </a>

                <form action="<%= request.getContextPath() %>/DriverServlet"
                      method="post"
                      style="display:inline"
                      onsubmit="return confirm('Are you sure you want to delete this driver?');">

                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="driverId"
                           value="<%= rs.getInt("driver_id") %>">

                    <button type="submit" class="delete">Delete</button>
                </form>
            </td>

        </tr>

        <%

                }

                rs.close();
                ps.close();
                con.close();

            } catch(Exception e) {

        %>

        <tr>

            <td colspan="7">

                Database Error:
                <%= e.getMessage() %>

            </td>

        </tr>

        <%

            }

        %>

    </table>

</div>


<script>

function showForm() {

    const form =
        document.getElementById("driverForm");

    if(form.style.display === "block") {

        form.style.display = "none";

    } else {

        form.style.display = "block";

    }

}
/* =========================
   OPEN SIDEBAR
========================= */

function openSidebar() {

    document
        .getElementById("sidebar")
        .classList
        .add("active");

    document
        .getElementById("overlay")
        .classList
        .add("active");
}


/* =========================
   CLOSE SIDEBAR
========================= */

function closeSidebar() {

    document
        .getElementById("sidebar")
        .classList
        .remove("active");

    document
        .getElementById("overlay")
        .classList
        .remove("active");
}
</script>

</body>

</html>