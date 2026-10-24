
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.manjare.DBConnection" %>

<%
    String editId = request.getParameter("edit");

    int editVehicleId = 0;
    boolean editMode = false;
    boolean editLoadError = false;

    String editVehicleNumber = "";
    String editModel = "";
    String editType = "";
    String editFuel = "";
    String editStatus = "Available";

    if (editId != null && editId.matches("\\d+")) {
        try {
            editVehicleId = Integer.parseInt(editId);

            String editSql =
                "SELECT * FROM vehicles WHERE vehicle_id = ?";

            try (
                Connection editCon = DBConnection.getConnection();
                PreparedStatement editPs = editCon.prepareStatement(editSql)
            ) {
                editPs.setInt(1, editVehicleId);

                try (ResultSet editRs = editPs.executeQuery()) {
                    if (editRs.next()) {
                        editMode = true;

                        editVehicleNumber =
                            editRs.getString("vehicle_number");

                        editModel =
                            editRs.getString("model");

                        editType =
                            editRs.getString("vehicle_type");

                        editFuel =
                            editRs.getString("fuel_type");

                        editStatus =
                            editRs.getString("status");
                    }
                }
            }
        } catch (Exception e) {
            application.log("Unable to load vehicle for editing", e);
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

    <title>Vehicles | Manjare Tours & Travels</title>

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

        .back-button {
            text-decoration: none;
            color: white;
            border: 1px solid #d4af37;
            padding: 10px 18px;
            border-radius: 6px;
            transition: 0.3s;
        }

        .back-button:hover {
            background: #d4af37;
            color: #07192b;
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

        /* =========================
           MAIN
           ========================= */

        .container {
            padding: 35px;
            max-width: 1400px;
            margin: auto;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .page-header h1 {
            font-size: 32px;
        }

        .add-button {
            border: none;
            background: #d4af37;
            color: #07192b;
            padding: 12px 20px;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
        }

        .add-button:hover {
            background: #f0cf55;
        }

        /* =========================
           MESSAGE
           ========================= */

        .message {
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            background: #163b55;
        }

        /* =========================
           FORM
           ========================= */

        .form-box {
            background: #0b2239;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: none;
        }

        .form-box h2 {
            margin-bottom: 20px;
            color: #d4af37;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            margin-bottom: 7px;
            font-size: 14px;
        }

        .form-group input,
        .form-group select {
            padding: 12px;
            border: none;
            border-radius: 5px;
            outline: none;
        }

        .save-button {
            margin-top: 20px;
            background: #d4af37;
            color: #07192b;
            border: none;
            padding: 12px 25px;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
        }

        .save-button:hover {
            background: #f0cf55;
        }

        .cancel-button {
            display: inline-block;
            margin-top: 20px;
            margin-left: 10px;
            background: transparent;
            color: white;
            border: 1px solid rgba(255,255,255,0.35);
            padding: 11px 20px;
            border-radius: 5px;
            text-decoration: none;
        }

        .cancel-button:hover {
            background: rgba(255,255,255,0.1);
        }

        /* =========================
           TABLE
           ========================= */

        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: #0b2239;
            border-radius: 10px;
            overflow: hidden;
        }

        th {
            background: #102f4d;
            color: #d4af37;
            padding: 15px;
            text-align: left;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }

        tr:hover {
            background: rgba(255,255,255,0.04);
        }

        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
        }

        .available {
            background: #1d613d;
        }

        .in-use {
            background: #66521a;
        }

        .maintenance {
            background: #693333;
        }

        .actions a {
            text-decoration: none;
            margin-right: 10px;
        }

        .edit {
            color: #d4af37;
        }

        .delete {
            color: #ff7070;
        }

        /* =========================
           RESPONSIVE
           ========================= */

        @media(max-width: 700px) {

            .navbar {
                padding: 0 18px;
            }

            .logo {
                font-size: 18px;
                letter-spacing: 2px;
            }

            .nav-left {
                gap: 12px;
            }

            .back-button {
                padding: 9px 10px;
                font-size: 13px;
            }

            .container {
                padding: 20px;
            }

            .page-header {
                align-items: flex-start;
                gap: 15px;
                flex-direction: column;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            table {
                font-size: 13px;
            }

            th,
            td {
                padding: 10px;
            }
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

        <button class="close-btn" onclick="closeSidebar()">
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

<!-- =========================
     NAVBAR
     ========================= -->

<div class="navbar">

    <div class="nav-left">

        <!-- HAMBURGER -->

        <button class="menu-btn" onclick="openSidebar()">
            <span></span>
            <span></span>
            <span></span>
        </button>

        <!-- LOGO -->

        <div class="logo">
            MANJARE
            <span>TOURS & TRAVELS</span>
        </div>

    </div>

    <a href="dashboard.jsp" class="back-button">
        ← Dashboard
    </a>

</div>

<!-- =========================
     MAIN
     ========================= -->

<div class="container">

    <div class="page-header">

        <h1>🚗 Vehicles</h1>

        <button
            class="add-button"
            onclick="window.location.href='vehicles.jsp?add=1'">

            + Add Vehicle

        </button>

    </div>

    <!-- =========================
         SUCCESS / ERROR MESSAGE
         ========================= -->

    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");

        if ("added".equals(success)) {
    %>
        <div class="message">Vehicle added successfully.</div>
    <%
        } else if ("updated".equals(success)) {
    %>
        <div class="message">Vehicle updated successfully.</div>
    <%
        } else if ("deleted".equals(success)) {
    %>
        <div class="message">Vehicle deleted successfully.</div>
    <%
        }

        if ("database".equals(error)) {
    %>
        <div class="message">
            Unable to save vehicle. Please check the database.
        </div>
    <%
        } else if ("inuse".equals(error)) {
    %>
        <div class="message">
            This vehicle cannot be deleted because it is being used by another record.
        </div>
    <%
        } else if ("invalidid".equals(error)) {
    %>
        <div class="message">Invalid vehicle ID.</div>
    <%
        } else if ("notfound".equals(error)) {
    %>
        <div class="message">Vehicle not found.</div>
    <%
        } else if ("invalidaction".equals(error)) {
    %>
        <div class="message">Invalid vehicle action.</div>
    <%
        }

        if (editLoadError) {
    %>
        <div class="message">
            Unable to load vehicle details. Please check the database.
        </div>
    <%
        } else if (editId != null && !editMode) {
    %>
        <div class="message">
            The requested vehicle could not be found.
        </div>
    <%
        }
    %>

    <!-- =========================
         ADD / EDIT VEHICLE FORM
         ========================= -->

    <div class="form-box" id="vehicleForm">

        <h2>
            <%= editMode ? "Edit Vehicle" : "Add Vehicle" %>
        </h2>

        <form action="<%= request.getContextPath() %>/VehicleServlet"
              method="post">

            <input
                type="hidden"
                name="action"
                value="<%= editMode ? "update" : "add" %>">

            <% if (editMode) { %>
                <input
                    type="hidden"
                    name="vehicleId"
                    value="<%= editVehicleId %>">
            <% } %>

            <div class="form-grid">

                <div class="form-group">

                    <label>Vehicle Number</label>

                    <input
                        type="text"
                        name="vehicleNumber"
                        placeholder="e.g. MH 02 AB 1234"
                        value="<%= editMode ? editVehicleNumber : "" %>"
                        required>

                </div>

                <div class="form-group">

                    <label>Model</label>

                    <input
                        type="text"
                        name="model"
                        placeholder="e.g. WagonR"
                        value="<%= editMode ? editModel : "" %>"
                        required>

                </div>

                <div class="form-group">

                    <label>Vehicle Type</label>

                    <select name="type" required>

                        <option value="">Select Type</option>

                        <option value="Hatchback"
                            <%= "Hatchback".equals(editType) && editMode ? "selected" : "" %>>
                            Hatchback
                        </option>

                        <option value="SUV"
                            <%= "SUV".equals(editType) && editMode ? "selected" : "" %>>
                            SUV
                        </option>

                        <option value="Sedan"
                            <%= "Sedan".equals(editType) && editMode ? "selected" : "" %>>
                            Sedan
                        </option>

                        <option value="MUV"
                            <%= "MUV".equals(editType) && editMode ? "selected" : "" %>>
                            MUV
                        </option>

                    </select>

                </div>

                <div class="form-group">

                    <label>Fuel</label>

                    <select name="fuel" required>

                        <option value="">Select Fuel</option>

                        <option value="CNG"
                            <%= "CNG".equals(editFuel) && editMode ? "selected" : "" %>>
                            CNG
                        </option>

                        <option value="Petrol"
                            <%= "Petrol".equals(editFuel) && editMode ? "selected" : "" %>>
                            Petrol
                        </option>

                        <option value="Diesel"
                            <%= "Diesel".equals(editFuel) && editMode ? "selected" : "" %>>
                            Diesel
                        </option>

                    </select>

                </div>

                <div class="form-group">

                    <label>Status</label>

                    <select name="status" required>

                        <option value="Available"
                            <%= "Available".equals(editStatus) ? "selected" : "" %>>
                            Available
                        </option>

                        <option value="In Use"
                            <%= "In Use".equals(editStatus) ? "selected" : "" %>>
                            In Use
                        </option>

                        <option value="Maintenance"
                            <%= "Maintenance".equals(editStatus) ? "selected" : "" %>>
                            Maintenance
                        </option>

                    </select>

                </div>

            </div>

            <button type="submit" class="save-button">
                <%= editMode ? "Update Vehicle" : "Save Vehicle" %>
            </button>

            <% if (editMode) { %>
                <a href="vehicles.jsp" class="cancel-button">
                    Cancel
                </a>
            <% } %>

        </form>

    </div>

    <!-- =========================
         VEHICLE TABLE
         ========================= -->

    <div class="table-container">

        <table>

            <thead>

                <tr>
                    <th>ID</th>
                    <th>Vehicle Number</th>
                    <th>Model</th>
                    <th>Type</th>
                    <th>Fuel</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody>

            <%
                try (
                    Connection con = DBConnection.getConnection();
                    PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM vehicles ORDER BY vehicle_id DESC"
                    );
                    ResultSet rs = ps.executeQuery()
                ) {

                    while (rs.next()) {

                        int currentVehicleId =
                            rs.getInt("vehicle_id");

                        String status =
                            rs.getString("status");

                        if (status == null) {
                            status = "";
                        }

                        String statusClass =
                            status.toLowerCase().replace(" ", "-");
            %>

                <tr>

                    <td>
                        <%= currentVehicleId %>
                    </td>

                    <td>
                        <%= rs.getString("vehicle_number") %>
                    </td>

                    <td>
                        <%= rs.getString("model") %>
                    </td>

                    <td>
                        <%= rs.getString("vehicle_type") %>
                    </td>

                    <td>
                        <%= rs.getString("fuel_type") %>
                    </td>

                    <td>
                        <span class="status <%= statusClass %>">
                            <%= status %>
                        </span>
                    </td>

                    <td class="actions">

                        <a
                            href="vehicles.jsp?edit=<%= currentVehicleId %>"
                            class="edit">

                            Edit

                        </a>

                        <form
                            action="<%= request.getContextPath() %>/VehicleServlet"
                            method="post"
                            style="display:inline;">

                            <input
                                type="hidden"
                                name="action"
                                value="delete">

                            <input
                                type="hidden"
                                name="vehicleId"
                                value="<%= currentVehicleId %>">

                            <button
                                type="submit"
                                class="delete"
                                style="background:none;border:none;cursor:pointer;font-size:inherit;"
                                onclick="return confirm('Are you sure you want to delete this vehicle?');">

                                Delete

                            </button>

                        </form>

                    </td>

                </tr>

            <%
                    }

                } catch (Exception e) {

                    application.log("Unable to load vehicles", e);
            %>

                <tr>
                    <td colspan="7">
                        Database Error: Unable to load vehicle records.
                    </td>
                </tr>

            <%
                }
            %>

            </tbody>

        </table>

    </div>

</div>

<script>

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

/* =========================
   SHOW / HIDE VEHICLE FORM
========================= */

function showForm() {

    const form = document.getElementById("vehicleForm");

    if (form.style.display === "block") {
        form.style.display = "none";
    } else {
        form.style.display = "block";
    }
}

/* =========================
   AUTOMATICALLY OPEN FORM
   FOR ADD OR EDIT
========================= */

window.addEventListener("DOMContentLoaded", function () {

    const urlParams = new URLSearchParams(window.location.search);

    const editRequested = urlParams.has("edit");
    const addRequested = urlParams.has("add");

    if (editRequested || addRequested) {
        document.getElementById("vehicleForm").style.display = "block";
    }

});

</script>

</body>

</html>
