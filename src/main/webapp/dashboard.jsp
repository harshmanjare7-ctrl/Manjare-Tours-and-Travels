<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.manjare.DBConnection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%!
    // =====================================================
    // GET COUNT
    // =====================================================

    public int getCount(Connection con, String sql) {

        int count = 0;

        try (
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }


    // =====================================================
    // GET TOTAL
    // =====================================================

    public double getTotal(Connection con, String sql) {

        double total = 0;

        try (
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                total = rs.getDouble(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }
%>


<%

    // =====================================================
    // DASHBOARD COUNTS
    // =====================================================

    int totalVehicles = 0;
    int availableVehicles = 0;
    int totalDrivers = 0;
    int totalCustomers = 0;
    int totalTrips = 0;
    int todayTrips = 0;
    int totalExpenses = 0;
    int totalPayments = 0;

    double todayIncome = 0;


    // =====================================================
    // CHART DATA
    // =====================================================

    StringBuilder monthLabels =
        new StringBuilder("[");

    StringBuilder incomeData =
        new StringBuilder("[");

    StringBuilder expenseData =
        new StringBuilder("[");

    StringBuilder tripTypeLabels =
        new StringBuilder("[");

    StringBuilder tripTypeData =
        new StringBuilder("[");

    List<String[]> serviceReminders = new ArrayList<>();
    boolean showServiceReminderPopup = false;
    Connection con = null;


    try {

        con = DBConnection.getConnection();
        // =============================================
// VEHICLE SERVICE REMINDERS - NEXT 7 DAYS
// =============================================


String reminderSql =
    "SELECT v.vehicle_number, " +
    "vm.maintenance_type, " +
    "vm.next_service_date, " +
    "DATEDIFF(vm.next_service_date, CURDATE()) AS days_left " +
    "FROM vehicle_maintenance vm " +
    "JOIN vehicles v ON vm.vehicle_id = v.vehicle_id " +
    "WHERE vm.next_service_date >= CURDATE() " +
    "AND vm.next_service_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY) " +
    "ORDER BY vm.next_service_date ASC";

try (
    PreparedStatement reminderPs =
        con.prepareStatement(reminderSql);

    ResultSet reminderRs =
        reminderPs.executeQuery()
) {
    while (reminderRs.next()) {

        serviceReminders.add(new String[] {
            reminderRs.getString("vehicle_number"),
            reminderRs.getString("maintenance_type"),
            reminderRs.getDate("next_service_date").toString(),
            reminderRs.getString("days_left")
        });
    }

} catch (Exception e) {
    e.printStackTrace();
}
// SHOW REMINDER ONLY ONCE AFTER SUCCESSFUL LOGIN
if (Boolean.TRUE.equals(
        session.getAttribute("showServiceReminderPopup"))) {

    showServiceReminderPopup = !serviceReminders.isEmpty();

    // Remove the flag so dashboard refresh won't show it again
    session.removeAttribute("showServiceReminderPopup");
}

        // =====================================================
        // VEHICLES
        // =====================================================

        totalVehicles = getCount(
            con,
            "SELECT COUNT(*) FROM vehicles"
        );


        availableVehicles = getCount(
            con,
            "SELECT COUNT(*) FROM vehicles WHERE status = 'Available'"
        );


        // =====================================================
        // DRIVERS
        // =====================================================

        totalDrivers = getCount(
            con,
            "SELECT COUNT(*) FROM drivers"
        );


        // =====================================================
        // CUSTOMERS
        // =====================================================

        totalCustomers = getCount(
            con,
            "SELECT COUNT(*) FROM customers"
        );


        // =====================================================
        // TRIPS
        // =====================================================

        totalTrips = getCount(
            con,
            "SELECT COUNT(*) FROM trips"
        );


        // =====================================================
        // TODAY'S TRIPS
        // =====================================================

        todayTrips = getCount(
            con,
            "SELECT COUNT(*) FROM trips WHERE start_date = CURRENT_DATE()"
        );


        // =====================================================
        // EXPENSES
        // =====================================================

        totalExpenses = getCount(
            con,
            "SELECT COUNT(*) FROM expenses"
        );


        // =====================================================
        // PAYMENTS
        // =====================================================

        totalPayments = getCount(
            con,
            "SELECT COUNT(*) FROM payments"
        );


        // =====================================================
        // TODAY'S INCOME
        // =====================================================

        todayIncome = getTotal(
            con,
            "SELECT COALESCE(SUM(amount),0) " +
            "FROM payments " +
            "WHERE payment_date = CURRENT_DATE() " +
            "AND payment_status = 'Paid'"
        );


        // =====================================================
        // MONTHLY INCOME + EXPENSES
        //
        // IMPORTANT:
        // We generate exactly 6 months.
        // Therefore income and expense arrays always
        // have the same number of values.
        // =====================================================

        LocalDate currentMonth =
            LocalDate.now().withDayOfMonth(1);

        DateTimeFormatter monthFormatter =
            DateTimeFormatter.ofPattern("MMM yyyy");


        for (int i = 5; i >= 0; i--) {

            LocalDate monthStart =
                currentMonth.minusMonths(i);

            LocalDate nextMonth =
                monthStart.plusMonths(1);


            String monthName =
                monthStart.format(monthFormatter);


            double monthlyIncome = 0;

            double monthlyExpense = 0;


            // =================================================
            // MONTHLY INCOME
            // =================================================

            String monthlyIncomeSql =
                "SELECT COALESCE(SUM(amount),0) " +
                "FROM payments " +
                "WHERE payment_status = 'Paid' " +
                "AND payment_date >= ? " +
                "AND payment_date < ?";


            try (
                PreparedStatement ps =
                    con.prepareStatement(monthlyIncomeSql)
            ) {

                ps.setDate(
                    1,
                    java.sql.Date.valueOf(monthStart)
                );

                ps.setDate(
                    2,
                    java.sql.Date.valueOf(nextMonth)
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    if (rs.next()) {

                        monthlyIncome =
                            rs.getDouble(1);
                    }
                }

            } catch (Exception e) {

                e.printStackTrace();
            }


            // =================================================
            // MONTHLY EXPENSE
            // =================================================

            String monthlyExpenseSql =
                "SELECT COALESCE(SUM(amount),0) " +
                "FROM expenses " +
                "WHERE expense_date >= ? " +
                "AND expense_date < ?";


            try (
                PreparedStatement ps =
                    con.prepareStatement(monthlyExpenseSql)
            ) {

                ps.setDate(
                    1,
                    java.sql.Date.valueOf(monthStart)
                );

                ps.setDate(
                    2,
                    java.sql.Date.valueOf(nextMonth)
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    if (rs.next()) {

                        monthlyExpense =
                            rs.getDouble(1);
                    }
                }

            } catch (Exception e) {

                e.printStackTrace();
            }


            // =================================================
            // ADD MONTH LABEL
            // =================================================

            monthLabels
                .append("\"")
                .append(monthName)
                .append("\"")
                .append(",");


            // =================================================
            // ADD INCOME
            // =================================================

            incomeData
                .append(monthlyIncome)
                .append(",");


            // =================================================
            // ADD EXPENSE
            // =================================================

            expenseData
                .append(monthlyExpense)
                .append(",");
        }


        // =====================================================
        // TRIP TYPE DATA
        // =====================================================

        String tripTypeSql =
            "SELECT trip_type, COUNT(*) AS total " +
            "FROM trips " +
            "WHERE trip_type IS NOT NULL " +
            "AND trip_type <> '' " +
            "GROUP BY trip_type " +
            "ORDER BY total DESC";


        try (
            PreparedStatement ps =
                con.prepareStatement(tripTypeSql);

            ResultSet rs =
                ps.executeQuery()
        ) {

            while (rs.next()) {

                String tripType =
                    rs.getString("trip_type");


                if (
                    tripType == null ||
                    tripType.trim().isEmpty()
                ) {

                    tripType = "Other";
                }


                // Escape backslash and quotes
                // so JavaScript remains valid.

                tripType =
                    tripType
                        .replace("\\", "\\\\")
                        .replace("\"", "\\\"");


                tripTypeLabels
                    .append("\"")
                    .append(tripType)
                    .append("\"")
                    .append(",");


                tripTypeData
                    .append(rs.getInt("total"))
                    .append(",");
            }

        } catch (Exception e) {

            e.printStackTrace();
        }


        // =====================================================
        // REMOVE TRAILING COMMAS
        // =====================================================

        if (
            monthLabels.length() > 1 &&
            monthLabels.charAt(
                monthLabels.length() - 1
            ) == ','
        ) {

            monthLabels.deleteCharAt(
                monthLabels.length() - 1
            );
        }


        if (
            incomeData.length() > 1 &&
            incomeData.charAt(
                incomeData.length() - 1
            ) == ','
        ) {

            incomeData.deleteCharAt(
                incomeData.length() - 1
            );
        }


        if (
            expenseData.length() > 1 &&
            expenseData.charAt(
                expenseData.length() - 1
            ) == ','
        ) {

            expenseData.deleteCharAt(
                expenseData.length() - 1
            );
        }


        if (
            tripTypeLabels.length() > 1 &&
            tripTypeLabels.charAt(
                tripTypeLabels.length() - 1
            ) == ','
        ) {

            tripTypeLabels.deleteCharAt(
                tripTypeLabels.length() - 1
            );
        }


        if (
            tripTypeData.length() > 1 &&
            tripTypeData.charAt(
                tripTypeData.length() - 1
            ) == ','
        ) {

            tripTypeData.deleteCharAt(
                tripTypeData.length() - 1
            );
        }


        // =====================================================
        // CLOSE JAVASCRIPT ARRAYS
        // =====================================================

        monthLabels.append("]");

        incomeData.append("]");

        expenseData.append("]");

        tripTypeLabels.append("]");

        tripTypeData.append("]");


    } catch (Exception e) {

        e.printStackTrace();

    } finally {

        try {

            if (con != null) {
                con.close();
            }

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        Dashboard | Manjare Tours & Travels
    </title>


    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }


        body {

            font-family:
                Arial,
                Helvetica,
                sans-serif;

            background:

                linear-gradient(
                    rgba(7, 25, 43, 0.35),
                    rgba(7, 25, 43, 0.50)
                ),

                url("images/dashboard-bg.png");

            background-size: cover;

            background-position:
                center top;

            background-attachment:
                fixed;

            background-repeat:
                no-repeat;

            color: white;

            min-height: 100vh;
        }


        /* =====================================================
           NAVBAR
        ===================================================== */

        .navbar {

            height: 80px;

            background: #0b2239;

            display: flex;

            align-items: center;

            justify-content:
                space-between;

            padding:
                0 40px;

            border-bottom:
                1px solid
                rgba(255,255,255,0.15);

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

            background:
                transparent;

            cursor: pointer;

            display: flex;

            flex-direction:
                column;

            justify-content:
                center;

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

            background:
                #f4b942;
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


        /* =====================================================
           RIGHT SIDE
        ===================================================== */

        .nav-right {

            display: flex;

            align-items: center;

            gap: 15px;
        }


        /* =====================================================
           SEARCH
        ===================================================== */

        .search-box {

            width: 280px;

            height: 42px;

            background:
                #07192b;

            border:
                1px solid
                rgba(255,255,255,0.15);

            border-radius: 8px;

            display: flex;

            align-items: center;

            padding:
                0 14px;

            transition: 0.3s;
        }


        .search-box:focus-within {

            border-color:
                #f4b942;

            box-shadow:

                0 0 0 2px
                rgba(244,185,66,0.1);
        }


        .search-icon {

            font-size: 18px;

            margin-right: 8px;

            color:
                rgba(255,255,255,0.6);
        }


        .search-box input {

            width: 100%;

            background:
                transparent;

            border: none;

            outline: none;

            color: white;

            font-size: 14px;
        }


        .search-box input::placeholder {

            color:
                rgba(255,255,255,0.5);
        }


        /* =====================================================
           LOGOUT
        ===================================================== */

        .logout {

            text-decoration: none;

            color: #07192b;

            background:
                #f4b942;

            padding:
                12px 22px;

            border-radius: 8px;

            font-weight: bold;

            transition: 0.3s;
        }


        .logout:hover {

            background:
                #ffd66b;

            transform:
                translateY(-1px);
        }


        /* =====================================================
           SIDEBAR
        ===================================================== */

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

            padding:
                25px 20px;

            box-shadow:
                5px 0 20px
                rgba(0,0,0,0.35);

            transition:
                left 0.35s ease;
        }


        .sidebar.active {

            left: 0;
        }


        .sidebar-header {

            display: flex;

            justify-content:
                space-between;

            align-items: center;

            padding-bottom:
                20px;

            border-bottom:
                1px solid
                rgba(255,255,255,0.12);

            margin-bottom:
                20px;
        }


        .sidebar-title {

            font-size: 21px;

            font-weight: bold;
        }


        .sidebar-title span {

            display: block;

            color:
                #f4b942;

            font-size: 10px;

            letter-spacing: 3px;

            margin-top: 4px;
        }


        .close-btn {

            background:
                transparent;

            border: none;

            color: white;

            font-size: 28px;

            cursor: pointer;
        }


        .close-btn:hover {

            color:
                #f4b942;
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

            color:
                rgba(255,255,255,0.85);

            padding:
                13px 15px;

            border-radius: 8px;

            font-size: 15px;

            transition: 0.25s;
        }


        .sidebar-menu a:hover {

            background:
                rgba(244,185,66,0.12);

            color:
                #f4b942;

            transform:
                translateX(4px);
        }


        .sidebar-icon {

            font-size: 20px;

            width: 25px;

            text-align: center;
        }


        /* =====================================================
           OVERLAY
        ===================================================== */

        .overlay {

            position: fixed;

            top: 0;

            left: 0;

            width: 100%;

            height: 100%;

            background:
                rgba(0,0,0,0.55);

            z-index: 1500;

            opacity: 0;

            visibility:
                hidden;

            transition: 0.3s;
        }


        .overlay.active {

            opacity: 1;

            visibility:
                visible;
        }


        /* =====================================================
           MAIN CONTAINER
        ===================================================== */

        .container {

            padding:
                45px;
        }


        /* =====================================================
           WELCOME
        ===================================================== */

        .welcome {

            margin-bottom:
                35px;
        }


        .welcome h1 {

            font-size: 36px;

            margin-bottom:
                10px;
        }


        .welcome p {

            color:
                rgba(255,255,255,0.65);

            font-size: 16px;
        }


        /* =====================================================
           SUMMARY CARDS
        ===================================================== */

        .cards {

            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap: 20px;
        }


        .card {

            background:
                #0b2239;

            padding:
                25px;

            border-radius:
                14px;

            border:
                1px solid
                rgba(255,255,255,0.1);

            transition:
                0.3s;
        }


        .card:hover {

            border-color:
                rgba(244,185,66,0.5);

            transform:
                translateY(-3px);
        }


        .card h3 {

            color:
                rgba(255,255,255,0.7);

            font-size:
                15px;

            margin-bottom:
                15px;
        }


        .card .number {

            font-size:
                32px;

            font-weight:
                bold;

            color:
                #f4b942;
        }


        /* =====================================================
           MANAGEMENT
        ===================================================== */

        .modules {

            margin-top:
                40px;
        }


        .modules h2 {

            margin-bottom:
                20px;

            font-size:
                28px;
        }


        .module-grid {

            display:
                grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap:
                20px;
        }


        /* =====================================================
           MODULE CARD
        ===================================================== */

        .module {

            background:
                #0b2239;

            border-radius:
                14px;

            border:
                1px solid
                rgba(255,255,255,0.1);

            overflow:
                hidden;

            cursor:
                pointer;

            transition:
                0.3s;

            min-width:
                0;
        }


        .module:hover {

            transform:
                translateY(-5px);

            border-color:
                #f4b942;

            box-shadow:

                0 8px 25px
                rgba(0,0,0,0.25);
        }


        .module-link {

            display:
                block;

            text-decoration:
                none;

            color:
                white;
        }


        .module-title {

            padding:
                20px 20px 15px;

            font-size:
                18px;

            font-weight:
                bold;
        }


        .module-image {

            width:
                100%;

            height:
                155px;

            object-fit:
                cover;

            display:
                block;
        }


        .module-content {

            padding:
                17px 20px 22px;
        }


        .module p {

            color:
                rgba(255,255,255,0.65);

            font-size:
                14px;

            line-height:
                1.5;
        }


        /* =====================================================
           NO SEARCH RESULTS
        ===================================================== */

        .no-results {

            display:
                none;

            text-align:
                center;

            color:
                rgba(255,255,255,0.5);

            padding:
                30px;

            font-size:
                16px;
        }


        /* =====================================================
           DASHBOARD CHARTS
        ===================================================== */

        .chart-section {

            margin-top:
                40px;
        }


        .chart-section h2 {

            margin-bottom:
                20px;

            font-size:
                28px;
        }


        .chart-grid {

            display:
                grid;

            grid-template-columns:
                2fr 1fr;

            gap:
                20px;
        }


        .chart-card {

            background:
                #0b2239;

            border:
                1px solid
                rgba(255,255,255,0.1);

            border-radius:
                14px;

            padding:
                25px;

            min-height:
                350px;
        }


        .chart-card h3 {

            color:
                #f4b942;

            margin-bottom:
                20px;
        }


        .chart-container {

            position:
                relative;

            height:
                270px;
        }


        /* =====================================================
           FOOTER
        ===================================================== */

        .dashboard-footer {

            margin-top:
                50px;

            background:
                #0b2239;

            border-top:
                1px solid
                rgba(255,255,255,0.15);

            padding:
                40px 45px 20px;
        }


        .footer-container {

            display:
                grid;

            grid-template-columns:
                2fr 1fr 1.5fr;

            gap:
                50px;

            max-width:
                1200px;

            margin:
                auto;
        }


        .footer-section h3 {

            color:
                #f4b942;

            font-size:
                18px;

            margin-bottom:
                15px;
        }


        .footer-section p {

            color:
                rgba(255,255,255,0.65);

            font-size:
                14px;

            line-height:
                1.7;

            margin:
                6px 0;
        }


        .footer-section a {

            display:
                block;

            text-decoration:
                none;

            color:
                rgba(255,255,255,0.65);

            font-size:
                14px;

            margin:
                9px 0;

            transition:
                0.25s;
        }


        .footer-section a:hover {

            color:
                #f4b942;

            transform:
                translateX(3px);
        }


        .footer-bottom {

            border-top:
                1px solid
                rgba(255,255,255,0.12);

            margin-top:
                30px;

            padding-top:
                18px;

            text-align:
                center;
        }


        .footer-bottom p {

            color:
                rgba(255,255,255,0.45);

            font-size:
                13px;

            margin:
                5px 0;
        }


        /* =====================================================
           RESPONSIVE
        ===================================================== */

        @media (max-width: 1100px) {

            .cards,
            .module-grid {

                grid-template-columns:
                    repeat(2, 1fr);
            }


            .search-box {

                width:
                    220px;
            }


            .footer-container {

                grid-template-columns:
                    1fr 1fr;
            }
        }


        @media (max-width: 900px) {

            .chart-grid {

                grid-template-columns:
                    1fr;
            }
        }


        @media (max-width: 700px) {

            .navbar {

                padding:
                    0 20px;
            }


            .container {

                padding:
                    25px 20px;
            }


            .cards,
            .module-grid {

                grid-template-columns:
                    1fr;
            }


            .search-box {

                width:
                    180px;
            }


            .logo {

                font-size:
                    19px;
            }


            .logo span {

                font-size:
                    8px;
            }


            .footer-container {

                grid-template-columns:
                    1fr;

                gap:
                    25px;
            }


            .dashboard-footer {

                padding:
                    35px 20px 20px;
            }
        }


        @media (max-width: 500px) {

            .nav-right {

                gap:
                    8px;
            }


            .search-box {

                width:
                    45px;

                padding:
                    0 12px;
            }


            .search-box input {

                display:
                    none;
            }


            .search-icon {

                margin:
                    0;
            }


            .logout {

                padding:
                    10px 14px;

                font-size:
                    12px;
            }


            .nav-left {

                gap:
                    12px;
            }
        }

    </style>


    <!-- =====================================================
         CHART.JS
    ====================================================== -->

    <script
        src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js">
    </script>

</head>


<body>


    <!-- =====================================================
         SIDEBAR
    ====================================================== -->

    <div
        class="sidebar"
        id="sidebar"
    >

        <div class="sidebar-header">

            <div class="sidebar-title">

                MANJARE

                <span>
                    TOURS & TRAVELS
                </span>

            </div>


            <button
                class="close-btn"
                onclick="closeSidebar()"
            >
                ×
            </button>

        </div>


        <ul class="sidebar-menu">


            <li>

                <a href="dashboard.jsp">

                    <span class="sidebar-icon">
                        🏠
                    </span>

                    Dashboard

                </a>

            </li>


            <li>

                <a href="vehicles.jsp">

                    <span class="sidebar-icon">
                        🚗
                    </span>

                    Vehicles

                </a>

            </li>


            <li>

                <a href="drivers.jsp">

                    <span class="sidebar-icon">
                        👨‍✈️
                    </span>

                    Drivers

                </a>

            </li>


            <li>

                <a href="customers.jsp">

                    <span class="sidebar-icon">
                        🧳
                    </span>

                    Customers

                </a>

            </li>


            <li>

                <a href="trips.jsp">

                    <span class="sidebar-icon">
                        🛣️
                    </span>

                    Trips

                </a>

            </li>


            <li>

                <a href="expenses.jsp">

                    <span class="sidebar-icon">
                        💰
                    </span>

                    Expenses

                </a>

            </li>


            <li>

                <a href="payments.jsp">

                    <span class="sidebar-icon">
                        💳
                    </span>

                    Payments

                </a>

            </li>


            <li>

                <a href="reports.jsp">

                    <span class="sidebar-icon">
                        📊
                    </span>

                    Reports

                </a>

            </li>


            <li>

                <a href="maintenance.jsp">

                    <span class="sidebar-icon">
                        🔧
                    </span>

                    Vehicle Maintenance

                </a>

            </li>


        </ul>

    </div>


    <!-- =====================================================
         SIDEBAR OVERLAY
    ====================================================== -->

    <div
        class="overlay"
        id="overlay"
        onclick="closeSidebar()">
    </div>


    <!-- =====================================================
         NAVBAR
    ====================================================== -->

    <div class="navbar">


        <div class="nav-left">


            <button
                class="menu-btn"
                onclick="openSidebar()"
            >

                <span></span>
                <span></span>
                <span></span>

            </button>


            <div class="logo">

                MANJARE

                <span>
                    TOURS & TRAVELS
                </span>

            </div>


        </div>


        <div class="nav-right">


            <!-- SEARCH -->

            <div class="search-box">

                <span class="search-icon">
                    🔍
                </span>


                <input
                    type="text"
                    id="searchInput"
                    placeholder="Search modules..."
                    onkeyup="searchModules()"
                >

            </div>


            <!-- LOGOUT -->

            <a
                href="index.jsp"
                class="logout"
            >
                LOGOUT
            </a>


        </div>


    </div>


    <!-- =====================================================
         MAIN
    ====================================================== -->

    <div class="container">


        <!-- =================================================
             WELCOME
        ================================================== -->

        <div class="welcome">

            <h1>
                Welcome Back, Mahesh
            </h1>

            <p>
                <b>
                    Manage your tours and travels
                    business from one place.
                </b>
            </p>

        </div>


        <!-- =================================================
             SUMMARY CARDS
        ================================================== -->

        <div class="cards">


            <div class="card">

                <h3>
                    Today's Trips
                </h3>

                <div class="number">

                    <%= todayTrips %>

                </div>

            </div>


            <div class="card">

                <h3>
                    Total Vehicles
                </h3>

                <div class="number">

                    <%= totalVehicles %>

                </div>

            </div>


            <div class="card">

                <h3>
                    Available Vehicles
                </h3>

                <div class="number">

                    <%= availableVehicles %>

                </div>

            </div>


            <div class="card">

                <h3>
                    Today's Income
                </h3>

                <div class="number">

                    ₹<%= String.format("%.2f", todayIncome) %>

                </div>

            </div>


        </div>


        <!-- =================================================
             MANAGEMENT
        ================================================== -->

        <div class="modules">


            <h2>
                Management
            </h2>


            <div
                class="module-grid"
                id="moduleGrid"
            >


                <!-- VEHICLES -->

                <div
                    class="module"
                    data-name="vehicles"
                >

                    <a
                        href="vehicles.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            🚗 Vehicles
                        </div>


                        <img
                            class="module-image"
                            src="images/vehicles.jpg"
                            alt="Vehicles"
                        >


                        <div class="module-content">

                            <p>

                                Manage vehicles and
                                their availability.

                                <br><br>

                                Total Vehicles:

                                <strong>
                                    <%= totalVehicles %>
                                </strong>

                            </p>

                        </div>

                    </a>

                </div>


                <!-- DRIVERS -->

                <div
                    class="module"
                    data-name="drivers"
                >

                    <a
                        href="drivers.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            👨‍✈️ Drivers
                        </div>


                        <img
                            class="module-image"
                            src="images/drivers.jpg"
                            alt="Drivers"
                        >


                        <div class="module-content">

                            <p>

                                Manage drivers and
                                assignments.

                                <br><br>

                                Total Drivers:

                                <strong>
                                    <%= totalDrivers %>
                                </strong>

                            </p>

                        </div>

                    </a>

                </div>


                <!-- CUSTOMERS -->

                <div
                    class="module"
                    data-name="customers"
                >

                    <a
                        href="customers.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            🧳 Customers
                        </div>


                        <img
                            class="module-image"
                            src="images/customers.jpg"
                            alt="Customers"
                        >


                        <div class="module-content">

                            <p>

                                Manage customer
                                information.

                                <br><br>

                                Total Customers:

                                <strong>
                                    <%= totalCustomers %>
                                </strong>

                            </p>

                        </div>

                    </a>

                </div>


                <!-- TRIPS -->

                <div
                    class="module"
                    data-name="trips"
                >

                    <a
                        href="trips.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            🛣️ Trips
                        </div>


                        <img
                            class="module-image"
                            src="images/trips.jpg"
                            alt="Trips"
                        >


                        <div class="module-content">

                            <p>

                                Manage daily and
                                private trips.

                                <br><br>

                                Total Trips:

                                <strong>
                                    <%= totalTrips %>
                                </strong>

                            </p>

                        </div>

                    </a>

                </div>


                <!-- EXPENSES -->

                <div
                    class="module"
                    data-name="expenses"
                >

                    <a
                        href="expenses.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            💰 Expenses
                        </div>


                        <img
                            class="module-image"
                            src="images/expenses.jpg"
                            alt="Expenses"
                        >


                        <div class="module-content">

                            <p>

                                Track fuel and
                                other expenses.

                                <br><br>

                                Total Records:

                                <strong>
                                    <%= totalExpenses %>
                                </strong>

                            </p>

                        </div>

                    </a>

                </div>


                <!-- PAYMENTS -->

                <div
                    class="module"
                    data-name="payments"
                >

                    <a
                        href="payments.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            💳 Payments
                        </div>


                        <img
                            class="module-image"
                            src="images/payments.jpg"
                            alt="Payments"
                        >


                        <div class="module-content">

                            <p>

                                Manage cash and
                                online payments.

                                <br><br>

                                Total Payments:

                                <strong>
                                    <%= totalPayments %>
                                </strong>

                            </p>

                        </div>

                    </a>

                </div>


                <!-- REPORTS -->

                <div
                    class="module"
                    data-name="reports"
                >

                    <a
                        href="reports.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            📊 Reports
                        </div>


                        <img
                            class="module-image"
                            src="images/reports.jpg"
                            alt="Reports"
                        >


                        <div class="module-content">

                            <p>

                                View business reports
                                and summaries.

                            </p>

                        </div>

                    </a>

                </div>


                <!-- VEHICLE MAINTENANCE -->

                <div
                    class="module"
                    data-name="maintenance"
                >

                    <a
                        href="maintenance.jsp"
                        class="module-link"
                    >

                        <div class="module-title">
                            🔧 Vehicle Maintenance
                        </div>


                        <img
                            class="module-image"
                            src="images/maintenance.png"
                            alt="Vehicle Maintenance"
                        >


                        <div class="module-content">

                            <p>

                                Track servicing, repairs
                                and maintenance expenses.

                            </p>

                        </div>

                    </a>

                </div>


            </div>


            <div
                class="no-results"
                id="noResults"
            >

                No matching module found.

            </div>


            <!-- =================================================
                 DASHBOARD CHARTS
            ================================================== -->

            <div class="chart-section">

                <h2>
                    Business Overview
                </h2>


                <div class="chart-grid">


                    <!-- INCOME VS EXPENSE -->

                    <div class="chart-card">

                        <h3>
                            Income vs Expenses
                        </h3>


                        <div class="chart-container">

                            <canvas
                                id="incomeExpenseChart">
                            </canvas>

                        </div>

                    </div>


                    <!-- TRIP TYPES -->

                    <div class="chart-card">

                        <h3>
                            Trip Types
                        </h3>


                        <div class="chart-container">

                            <canvas
                                id="tripTypeChart">
                            </canvas>

                        </div>

                    </div>


                </div>

            </div>


        </div>


    </div>

    
<!-- VEHICLE SERVICE REMINDER POPUP -->
<% if (showServiceReminderPopup) { %>

<div id="serviceReminderOverlay"
     style="display:none; position:fixed; inset:0;
            background:rgba(0,0,0,0.6); z-index:99999;
            align-items:center; justify-content:center;
            padding:20px;">

    <div style="background:white; color:#222; width:100%;
                max-width:520px; max-height:80vh;
                overflow-y:auto; border-radius:14px;
                padding:25px; box-shadow:0 10px 35px #0004;">

        <div style="display:flex; justify-content:space-between;
                    align-items:center; gap:10px;">

            <h2 style="margin:0; color:#b45309;">
                ⚠️ Vehicle Service Reminder
            </h2>

            <button type="button"
                    onclick="closeServiceReminder()"
                    style="border:none; background:none;
                           font-size:26px; cursor:pointer;">
                &times;
            </button>
        </div>

        <p style="margin:15px 0;">
            The following vehicles have service due within 7 days:
        </p>

        <% for (String[] reminder : serviceReminders) { %>

            <div style="border:1px solid #f0c36d;
                        background:#fffaf0; border-radius:10px;
                        padding:14px; margin:12px 0;">

                <strong>Vehicle:</strong>
                <%= reminder[0] %>
                <br>

                <strong>Maintenance:</strong>
                <%= reminder[1] %>
                <br>

                <strong>Next service date:</strong>
                <%= reminder[2] %>
                <br>

                <strong>
                    <%
                        int daysLeft = Integer.parseInt(reminder[3]);

                        if (daysLeft == 0) {
                            out.print("Service is due today!");
                        } else {
                            out.print("Days remaining: " + daysLeft);
                        }
                    %>
                </strong>

            </div>

        <% } %>

        <button type="button"
                onclick="closeServiceReminder()"
                style="width:100%; padding:12px;
                       border:none; border-radius:8px;
                       background:#b45309; color:white;
                       font-weight:bold; cursor:pointer;">
            Got it, close reminder
        </button>

    </div>
</div>

<% } %>
<!-- END VEHICLE SERVICE REMINDER POPUP -->


    <!-- =====================================================
         FOOTER
    ====================================================== -->

    <footer class="dashboard-footer">


        <div class="footer-container">


            <!-- ABOUT -->

            <div class="footer-section">

                <h3>
                    Manjare Tours & Travels
                </h3>


                <p>

                    A simple and efficient management
                    system designed to manage vehicles,
                    drivers, customers, trips, expenses
                    and payments in one place.

                </p>


                <p>

                    Designed & Developed by

                    <strong>
                        Your Name
                    </strong>

                </p>

            </div>


            <!-- QUICK LINKS -->

            <div class="footer-section">

                <h3>
                    Quick Links
                </h3>


                <a href="dashboard.jsp">
                    Dashboard
                </a>


                <a href="vehicles.jsp">
                    Vehicles
                </a>


                <a href="drivers.jsp">
                    Drivers
                </a>


                <a href="customers.jsp">
                    Customers
                </a>


                <a href="reports.jsp">
                    Reports
                </a>

            </div>


            <!-- DEVELOPER DETAILS -->

            <div class="footer-section">

                <h3>
                    Developer Details
                </h3>


                <p>
                    👤 Name:
                    <strong>
                        Mahesh Manjare
                    </strong>
                </p>


                <p>
                    📍 Address:
                    <strong>
                        302, Dhaval Apt, NL Cross Road,
                        Somwar Bazar Malad (West),
                        Mumbai - 400064
                    </strong>
                </p>


                <p>
                    📧 Email:
                    <strong>
                        maheshmanjare47@gmail.com
                    </strong>
                </p>


                <p>
                    📱 Contact:
                    <strong>
                        +91 9819141595
                    </strong>
                </p>

            </div>


        </div>


        <!-- FOOTER BOTTOM -->

        <div class="footer-bottom">

            <p>

                © 2026 Manjare Tours & Travels.
                All Rights Reserved.

            </p>


            <p>

                Tours & Travels Management System

            </p>

        </div>


    </footer>


    <!-- =====================================================
         JAVASCRIPT
    ====================================================== -->

    <script>


        // =====================================================
        // OPEN SIDEBAR
        // =====================================================

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


        // =====================================================
        // CLOSE SIDEBAR
        // =====================================================

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


        // =====================================================
        // SEARCH MODULES
        // =====================================================

        function searchModules() {


            let input =
                document
                    .getElementById("searchInput")
                    .value
                    .toLowerCase()
                    .trim();


            let modules =
                document
                    .querySelectorAll(".module");


            let found = false;


            modules.forEach(
                function(module) {


                    let name =
                        module
                            .getAttribute("data-name")
                            .toLowerCase();


                    if (
                        name.includes(input)
                    ) {

                        module.style.display =
                            "block";

                        found = true;

                    } else {

                        module.style.display =
                            "none";
                    }

                }
            );


            let noResults =
                document
                    .getElementById("noResults");


            if (!found) {

                noResults.style.display =
                    "block";

            } else {

                noResults.style.display =
                    "none";
            }

        }


        // =====================================================
        // DASHBOARD CHARTS
        // =====================================================

        document.addEventListener(
            "DOMContentLoaded",
            function () {


                // -------------------------------------------------
                // CHECK CHART.JS
                // -------------------------------------------------

                if (
                    typeof Chart === "undefined"
                ) {

                    console.error(
                        "Chart.js was not loaded."
                    );

                    return;
                }


                // =================================================
                // JSP DATA → JAVASCRIPT
                //
                // IMPORTANT:
                // These JSP expressions directly output the
                // Java StringBuilder arrays.
                // =================================================

                const monthLabels =
                    <%= monthLabels.toString() %>;


                const incomeData =
                    <%= incomeData.toString() %>;


                const expenseData =
                    <%= expenseData.toString() %>;


                const tripTypeLabels =
                    <%= tripTypeLabels.toString() %>;


                const tripTypeData =
                    <%= tripTypeData.toString() %>;


                // =================================================
                // DEBUG
                // =================================================

                console.log(
                    "Month Labels:",
                    monthLabels
                );


                console.log(
                    "Income Data:",
                    incomeData
                );


                console.log(
                    "Expense Data:",
                    expenseData
                );


                console.log(
                    "Trip Type Labels:",
                    tripTypeLabels
                );


                console.log(
                    "Trip Type Data:",
                    tripTypeData
                );


                // =================================================
                // INCOME VS EXPENSE CHART
                // =================================================

                const incomeExpenseCanvas =
                    document.getElementById(
                        "incomeExpenseChart"
                    );


                if (
                    incomeExpenseCanvas
                ) {

                    new Chart(
                        incomeExpenseCanvas,
                        {

                            type: "bar",


                            data: {

                                labels:
                                    monthLabels,


                                datasets: [

                                    {

                                        label:
                                            "Income",

                                        data:
                                            incomeData,

                                        borderWidth:
                                            1

                                    },


                                    {

                                        label:
                                            "Expenses",

                                        data:
                                            expenseData,

                                        borderWidth:
                                            1

                                    }

                                ]

                            },


                            options: {

                                responsive:
                                    true,

                                maintainAspectRatio:
                                    false,


                                plugins: {

                                    legend: {

                                        labels: {

                                            color:
                                                "white"

                                        }

                                    }

                                },


                                scales: {

                                    x: {

                                        ticks: {

                                            color:
                                                "rgba(255,255,255,0.7)"

                                        },


                                        grid: {

                                            color:
                                                "rgba(255,255,255,0.08)"

                                        }

                                    },


                                    y: {

                                        beginAtZero:
                                            true,


                                        ticks: {

                                            color:
                                                "rgba(255,255,255,0.7)"

                                        },


                                        grid: {

                                            color:
                                                "rgba(255,255,255,0.08)"

                                        }

                                    }

                                }

                            }

                        }
                    );

                }


                // =================================================
                // TRIP TYPE CHART
                // =================================================

                const tripTypeCanvas =
                    document.getElementById(
                        "tripTypeChart"
                    );


                if (
                    tripTypeCanvas
                ) {


                    let finalTripLabels =
                        tripTypeLabels;


                    let finalTripData =
                        tripTypeData;


                    // If there are no trip types,
                    // show a small placeholder.

                    if (
                        finalTripLabels.length === 0
                    ) {

                        finalTripLabels =
                            ["No Trips Yet"];


                        finalTripData =
                            [1];
                    }


                    new Chart(
                        tripTypeCanvas,
                        {

                            type:
                                "doughnut",


                            data: {

                                labels:
                                    finalTripLabels,


                                datasets: [

                                    {

                                        data:
                                            finalTripData,

                                        borderWidth:
                                            1

                                    }

                                ]

                            },


                            options: {

                                responsive:
                                    true,

                                maintainAspectRatio:
                                    false,


                                plugins: {

                                    legend: {

                                        position:
                                            "bottom",


                                        labels: {

                                            color:
                                                "white"

                                        }

                                    }

                                }

                            }

                        }
                    );

                }


            }
        );
// =============================================
// AUTO-OPEN VEHICLE SERVICE REMINDER
// =============================================

window.addEventListener("load", function () {

    const reminderPopup =
        document.getElementById("serviceReminderOverlay");

    if (reminderPopup) {
        reminderPopup.style.display = "flex";
    }

});

function closeServiceReminder() {

    const reminderPopup =
        document.getElementById("serviceReminderOverlay");

    if (reminderPopup) {
        reminderPopup.style.display = "none";
    }

}

    </script>


</body>

</html>