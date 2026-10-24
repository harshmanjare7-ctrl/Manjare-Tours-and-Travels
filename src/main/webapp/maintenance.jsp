<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.manjare.DBConnection" %>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Vehicle Maintenance | Manjare Tours & Travels</title>


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


        .back-btn {

            text-decoration: none;

            background: #f4b942;

            color: #07192b;

            padding: 11px 20px;

            border-radius: 7px;

            font-weight: bold;

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

            padding: 40px;

        }


        .page-title {

            margin-bottom: 30px;

        }


        .page-title h1 {

            font-size: 32px;

            margin-bottom: 8px;

        }


        .page-title p {

            color:
                rgba(255,255,255,0.6);

        }


        .form-card {

            background: #0b2239;

            border: 1px solid
                rgba(255,255,255,0.1);

            border-radius: 14px;

            padding: 30px;

            margin-bottom: 35px;

        }


        .form-card h2 {

            color: #f4b942;

            margin-bottom: 25px;

        }


        .form-grid {

            display: grid;

            grid-template-columns:
                repeat(2, 1fr);

            gap: 20px;

        }


        .form-group {

            display: flex;

            flex-direction: column;

        }


        .form-group label {

            margin-bottom: 8px;

            color:
                rgba(255,255,255,0.75);

            font-size: 14px;

        }


        .form-group input,

        .form-group select,

        .form-group textarea {

            padding: 12px;

            border-radius: 7px;

            border: 1px solid
                rgba(255,255,255,0.15);

            background: #07192b;

            color: white;

            outline: none;

        }


        .form-group textarea {

            resize: vertical;

            min-height: 90px;

        }


        .full {

            grid-column: 1 / -1;

        }


        .submit-btn {

            margin-top: 20px;

            background: #f4b942;

            color: #07192b;

            border: none;

            padding: 13px 25px;

            border-radius: 7px;

            font-weight: bold;

            cursor: pointer;

        }


        .table-card {

            background: #0b2239;

            border: 1px solid
                rgba(255,255,255,0.1);

            border-radius: 14px;

            padding: 30px;

            overflow-x: auto;

        }


        .table-card h2 {

            color: #f4b942;

            margin-bottom: 20px;

        }


        table {

            width: 100%;

            border-collapse: collapse;

        }


        th {

            background: #07192b;

            color: #f4b942;

            padding: 13px;

            text-align: left;

        }


        td {

            padding: 13px;

            border-bottom:
                1px solid
                rgba(255,255,255,0.08);

            color:
                rgba(255,255,255,0.8);

        }


        .delete-btn {

            background: #b83232;

            color: white;

            border: none;

            padding: 7px 12px;

            border-radius: 5px;

            cursor: pointer;

        }


        .message {

            margin-bottom: 20px;

            padding: 12px;

            border-radius: 7px;

            background:
                rgba(244,185,66,0.12);

            color: #f4b942;

        }


        @media(max-width:700px) {

            .container {

                padding: 25px 20px;

            }

            .form-grid {

                grid-template-columns: 1fr;

            }

            .full {

                grid-column: auto;

            }

            .navbar {

                padding: 0 20px;

            }

            .logo {

                font-size: 19px;

            }

        }

    </style>

</head>


<body>
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
           class="back-btn">

            ← Dashboard

        </a>

    </div>


    <div class="container">


        <div class="page-title">

            <h1>
                Vehicle Maintenance
            </h1>

            <p>
                Track vehicle servicing,
                repairs and maintenance expenses.
            </p>

        </div>


        <%
            String success =
                request.getParameter("success");

            String error =
                request.getParameter("error");

            if ("added".equals(success)) {
        %>

            <div class="message">
                Maintenance record added successfully.
            </div>

        <%
            }

            if ("deleted".equals(success)) {
        %>

            <div class="message">
                Maintenance record deleted successfully.
            </div>

        <%
            }

            if (error != null) {
        %>

            <div class="message">
                Unable to process the maintenance record.
            </div>

        <%
            }
        %>


        <!-- ADD MAINTENANCE -->

        <div class="form-card">

            <h2>
                Add Maintenance Record
            </h2>


            <form action="MaintenanceServlet"
                  method="post">

                <input type="hidden"
                       name="action"
                       value="add">


                <div class="form-grid">


                    <div class="form-group">

                        <label>
                            Vehicle
                        </label>

                        <select name="vehicle_id"
                                required>

                            <option value="">
                                Select Vehicle
                            </option>

                            <%

                                try (
                                    Connection con =
                                        DBConnection.getConnection();

                                    PreparedStatement ps =
                                        con.prepareStatement(
                                            "SELECT * FROM vehicles"
                                        );

                                    ResultSet rs =
                                        ps.executeQuery()
                                ) {

                                    while (rs.next()) {

                            %>

                                <option value="<%= rs.getInt("vehicle_id") %>">

                                    <%= rs.getString("vehicle_number") %>

                                </option>

                            <%

                                    }

                                } catch (Exception e) {

                                    e.printStackTrace();

                                }

                            %>

                        </select>

                    </div>


                    <div class="form-group">

                        <label>
                            Maintenance Type
                        </label>

                        <select name="maintenance_type"
                                required>

                            <option value="">
                                Select Type
                            </option>

                            <option value="Regular Service">
                                Regular Service
                            </option>

                            <option value="Oil Change">
                                Oil Change
                            </option>

                            <option value="Repair">
                                Repair
                            </option>

                            <option value="Tyre Replacement">
                                Tyre Replacement
                            </option>

                            <option value="Battery">
                                Battery
                            </option>

                            <option value="Other">
                                Other
                            </option>

                        </select>

                    </div>


                    <div class="form-group">

                        <label>
                            Maintenance Date
                        </label>

                        <input type="date"
                               name="maintenance_date"
                               required>

                    </div>


                    <div class="form-group">

                        <label>
                            Cost (₹)
                        </label>

                        <input type="number"
                               name="cost"
                               min="0"
                               step="0.01"
                               required>

                    </div>


                    <div class="form-group">

                        <label>
                            Next Service Date
                        </label>

                        <input type="date"
                               name="next_service_date">

                    </div>


                    <div class="form-group full">

                        <label>
                            Description
                        </label>

                        <textarea
                            name="description"
                            placeholder="Enter maintenance details...">
                        </textarea>

                    </div>


                </div>


                <button type="submit"
                        class="submit-btn">

                    + Add Maintenance

                </button>

            </form>

        </div>


        <!-- MAINTENANCE RECORDS -->

        <div class="table-card">

            <h2>
                Maintenance Records
            </h2>


            <table>

                <thead>

                    <tr>

                        <th>
                            Vehicle
                        </th>

                        <th>
                            Type
                        </th>

                        <th>
                            Date
                        </th>

                        <th>
                            Cost
                        </th>

                        <th>
                            Next Service
                        </th>

                        <th>
                            Description
                        </th>

                        <th>
                            Action
                        </th>

                    </tr>

                </thead>


                <tbody>

                <%

                    String sql =
                        "SELECT vm.*, " +
                        "v.vehicle_number " +
                        "FROM vehicle_maintenance vm " +
                        "JOIN vehicles v " +
                        "ON vm.vehicle_id = v.vehicle_id " +
                        "ORDER BY vm.maintenance_date DESC";


                    try (
                        Connection con =
                            DBConnection.getConnection();

                        PreparedStatement ps =
                            con.prepareStatement(sql);

                        ResultSet rs =
                            ps.executeQuery()
                    ) {

                        while (rs.next()) {

                %>

                    <tr>

                        <td>
                            <%= rs.getString("vehicle_number") %>
                        </td>

                        <td>
                            <%= rs.getString("maintenance_type") %>
                        </td>

                        <td>
                            <%= rs.getDate("maintenance_date") %>
                        </td>

                        <td>
                            ₹<%= String.format(
                                "%.2f",
                                rs.getDouble("cost")
                            ) %>
                        </td>

                        <td>
                            <%= rs.getDate("next_service_date") %>
                        </td>

                        <td>
                            <%= rs.getString("description") %>
                        </td>

                        <td>

                            <form action="MaintenanceServlet"
                                  method="post"
                                  onsubmit="return confirm(
                                    'Delete this maintenance record?'
                                  );">

                                <input type="hidden"
                                       name="action"
                                       value="delete">

                                <input type="hidden"
                                       name="maintenance_id"
                                       value="<%= rs.getInt("maintenance_id") %>">

                                <button
                                    type="submit"
                                    class="delete-btn">

                                    Delete

                                </button>

                            </form>

                        </td>

                    </tr>

                <%

                        }

                    } catch (Exception e) {

                        e.printStackTrace();

                %>

                    <tr>

                        <td colspan="7">

                            Unable to load
                            maintenance records.

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
</script>
</body>

</html>