<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Reports | Manjare Tours & Travels</title>

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

            padding: 40px;

        }

        .page-title {

            margin-bottom: 30px;

        }

        .page-title h1 {

            font-size: 36px;

            margin-bottom: 8px;

        }

        .page-title p {

            color:
                rgba(255,255,255,0.65);

        }

        .filter-box {

            background: #0b2239;

            padding: 25px;

            border-radius: 14px;

            border:
                1px solid rgba(255,255,255,0.1);

            margin-bottom: 30px;

        }

        .filter-box h2 {

            margin-bottom: 20px;

            font-size: 20px;

        }

        .filters {

            display: flex;

            gap: 15px;

            align-items: end;

            flex-wrap: wrap;

        }

        .input-group {

            display: flex;

            flex-direction: column;

            gap: 7px;

        }

        .input-group label {

            color:
                rgba(255,255,255,0.7);

            font-size: 13px;

        }

        .input-group input {

            background: #07192b;

            color: white;

            border: 1px solid
                rgba(255,255,255,0.15);

            border-radius: 7px;

            padding: 11px;

        }

        .generate-button {

            border: none;

            background: #f4b942;

            color: #07192b;

            padding: 12px 22px;

            border-radius: 7px;

            font-weight: bold;

            cursor: pointer;

        }

        .summary-grid {

            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap: 20px;

            margin-bottom: 30px;

        }

        .summary-card {

            background: #0b2239;

            padding: 25px;

            border-radius: 14px;

            border:
                1px solid rgba(255,255,255,0.1);

        }

        .summary-card h3 {

            color:
                rgba(255,255,255,0.65);

            font-size: 14px;

            margin-bottom: 12px;

        }

        .summary-card .value {

            color: #f4b942;

            font-size: 30px;

            font-weight: bold;

        }

        .report-section {

            background: #0b2239;

            padding: 25px;

            border-radius: 14px;

            margin-bottom: 25px;

            border:
                1px solid rgba(255,255,255,0.1);

        }

        .report-section h2 {

            margin-bottom: 20px;

        }

        table {

            width: 100%;

            border-collapse: collapse;

        }

        th,
        td {

            padding: 13px;

            text-align: left;

            border-bottom:
                1px solid
                rgba(255,255,255,0.1);

        }

        th {

            color: #f4b942;

        }

        td {

            color:
                rgba(255,255,255,0.8);

        }

        .print-button {

            border: none;

            background: #f4b942;

            color: #07192b;

            padding: 13px 25px;

            border-radius: 8px;

            font-weight: bold;

            cursor: pointer;

            margin-bottom: 30px;

        }

        @media(max-width:900px) {

            .summary-grid {

                grid-template-columns:
                    repeat(2,1fr);

            }

        }

        @media(max-width:600px) {

            .container {

                padding: 20px;

            }

            .summary-grid {

                grid-template-columns: 1fr;

            }

        }

        @media print {

            .navbar,
            .filter-box,
            .print-button {

                display: none;

            }

            body {

                background: white;

                color: black;

            }

            .report-section,
            .summary-card {

                color: black;

                border: 1px solid #ccc;

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


        <!-- TITLE -->

        <div class="page-title">

            <h1>
                Business Reports
            </h1>

            <p>
                View income, expenses, trips and
                payment summaries.
            </p>

        </div>


        <!-- DATE FILTER -->

        <div class="filter-box">

            <h2>
                Generate Report
            </h2>


            <form
                action="ReportServlet"
                method="get">

                <div class="filters">


                    <div class="input-group">

                        <label>
                            From Date
                        </label>

                        <input
                            type="date"
                            name="fromDate"
                            required>

                    </div>


                    <div class="input-group">

                        <label>
                            To Date
                        </label>

                        <input
                            type="date"
                            name="toDate"
                            required>

                    </div>


                    <button
                        type="submit"
                        class="generate-button">

                        GENERATE REPORT

                    </button>


                </div>

            </form>

        </div>


        <!-- SUMMARY -->

        <div class="summary-grid">

    <div class="summary-card">

        <h3>TOTAL INCOME</h3>

        <div class="value">
            ₹<%= String.format(
                "%.2f",
                request.getAttribute("totalIncome") != null
                    ? (Double) request.getAttribute("totalIncome")
                    : 0.0
            ) %>
        </div>

    </div>


    <div class="summary-card">

        <h3>TOTAL EXPENSES</h3>

        <div class="value">
            ₹<%= String.format(
                "%.2f",
                request.getAttribute("totalExpenses") != null
                    ? (Double) request.getAttribute("totalExpenses")
                    : 0.0
            ) %>
        </div>

    </div>


    <div class="summary-card">

        <h3>NET INCOME</h3>

        <div class="value">
            ₹<%= String.format(
                "%.2f",
                request.getAttribute("netIncome") != null
                    ? (Double) request.getAttribute("netIncome")
                    : 0.0
            ) %>
        </div>

    </div>


    <div class="summary-card">

        <h3>TOTAL TRIPS</h3>

        <div class="value">
            <%= request.getAttribute("totalTrips") != null
                ? request.getAttribute("totalTrips")
                : 0 %>
        </div>

    </div>

</div>


        <!-- INCOME -->

        <div class="report-section">

    <h2>
        💰 Income Summary
    </h2>

    <table>

        <thead>

            <tr>
                <th>Income Type</th>
                <th>Amount</th>
            </tr>

        </thead>

        <tbody>

            <tr>

                <td>
                    Cash Income
                </td>

                <td>
                    ₹<%= String.format(
                        "%.2f",
                        request.getAttribute("cashIncome") != null
                            ? (Double) request.getAttribute("cashIncome")
                            : 0.0
                    ) %>
                </td>

            </tr>


            <tr>

                <td>
                    Online Income
                </td>

                <td>
                    ₹<%= String.format(
                        "%.2f",
                        request.getAttribute("onlineIncome") != null
                            ? (Double) request.getAttribute("onlineIncome")
                            : 0.0
                    ) %>
                </td>

            </tr>


            <tr>

                <th>
                    Total Income
                </th>

                <th>
                    ₹<%= String.format(
                        "%.2f",
                        request.getAttribute("totalIncome") != null
                            ? (Double) request.getAttribute("totalIncome")
                            : 0.0
                    ) %>
                </th>

            </tr>

        </tbody>

    </table>

</div>


        <!-- EXPENSES -->

        <div class="report-section">

            <h2>
                💸 Expense Summary
            </h2>


            <table>

                <thead>

                    <tr>

                        <th>
                            Expense Type
                        </th>

                        <th>
                            Amount
                        </th>

                    </tr>

                </thead>


                <tbody>

                    <tr>

                        <td>
                            Fuel
                        </td>

                        <td>
                            ₹0
                        </td>

                    </tr>

                    <tr>

                        <td>
                            Maintenance
                        </td>

                        <td>
                            ₹0
                        </td>

                    </tr>

                    <tr>

                        <td>
                            Other
                        </td>

                        <td>
                            ₹0
                        </td>

                    </tr>

                    <tr>

                        <th>
                            Total Expenses
                        </th>

                        <th>
                            ₹0
                        </th>

                    </tr>

                </tbody>

            </table>

        </div>


        <!-- PAYMENT -->

        <div class="report-section">

    <h2>
        💳 Payment Summary
    </h2>

    <table>

        <thead>

            <tr>
                <th>Payment Mode</th>
                <th>Amount</th>
            </tr>

        </thead>


        <tbody>

            <tr>

                <td>
                    Cash
                </td>

                <td>
                    ₹<%= String.format(
                        "%.2f",
                        request.getAttribute("cashIncome") != null
                            ? (Double) request.getAttribute("cashIncome")
                            : 0.0
                    ) %>
                </td>

            </tr>


            <tr>

                <td>
                    Online
                </td>

                <td>
                    ₹<%= String.format(
                        "%.2f",
                        request.getAttribute("onlineIncome") != null
                            ? (Double) request.getAttribute("onlineIncome")
                            : 0.0
                    ) %>
                </td>

            </tr>


            <tr>

                <td>
                    Pending
                </td>

                <td>
                    ₹<%= String.format(
                        "%.2f",
                        request.getAttribute("pendingPayments") != null
                            ? (Double) request.getAttribute("pendingPayments")
                            : 0.0
                    ) %>
                </td>

            </tr>

        </tbody>

    </table>

</div>


        <button
            class="print-button"
            onclick="window.print()">

            🖨 PRINT REPORT

        </button>


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