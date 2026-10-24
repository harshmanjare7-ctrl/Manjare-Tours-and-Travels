
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.manjare.DBConnection" %>

<%!
    public String escapeHtml(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Payments | Manjare Tours & Travels</title>

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

        .back:hover {
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
            overflow-y: auto;
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
            padding: 4px 10px;
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
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
        }

        button {
            background: #d4af37;
            color: #07192b;
            border: none;
            padding: 12px 20px;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.2s;
        }

        button:hover {
            background: #f4b942;
            transform: translateY(-1px);
        }

        .form {
            display: none;
            background: #0b2239;
            padding: 25px;
            border: 1px solid rgba(244,185,66,0.25);
            border-radius: 10px;
            margin-bottom: 30px;
        }

        .form h2 {
            color: #d4af37;
            margin-bottom: 20px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
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
            border: 1px solid #d5dce4;
            border-radius: 5px;
            font-size: 14px;
            background: white;
            color: #172536;
        }

        input:focus,
        select:focus {
            outline: 2px solid #f4b942;
            border-color: #d4af37;
        }

        .form-buttons {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 20px;
        }

        .cancel {
            background: #506477;
            color: white;
        }

        .cancel:hover {
            background: #667e92;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        }

        table {
            width: 100%;
            min-width: 1050px;
            border-collapse: collapse;
            background: #0b2239;
        }

        th {
            background: #102f4d;
            color: #d4af37;
            padding: 15px;
            text-align: left;
            white-space: nowrap;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            vertical-align: middle;
        }

        tbody tr:hover {
            background: rgba(255,255,255,0.04);
        }

        .message {
            background: #163b55;
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 6px;
            border-left: 4px solid #f4b942;
        }

        .actions {
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }

        .edit-btn,
        .delete-btn {
            padding: 8px 12px;
            font-size: 13px;
        }

        .edit-btn {
            background: #f4b942;
        }

        .delete-btn {
            background: #c0392b;
            color: white;
        }

        .delete-btn:hover {
            background: #e74c3c;
        }

        .status {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            white-space: nowrap;
        }

        .status-paid {
            background: rgba(46,204,113,0.18);
            color: #72e6a0;
        }

        .status-pending {
            background: rgba(244,185,66,0.18);
            color: #f4b942;
        }

        .status-refunded {
            background: rgba(231,76,60,0.18);
            color: #ff9187;
        }

        .empty-message {
            text-align: center;
            padding: 25px;
            color: #cbd5df;
        }

        @media (max-width: 700px) {
            .navbar {
                padding: 0 15px;
            }

            .nav-left {
                gap: 10px;
            }

            .logo {
                font-size: 18px;
                letter-spacing: 2px;
            }

            .logo span {
                font-size: 9px;
                letter-spacing: 2px;
            }

            .back {
                padding: 9px 10px;
                font-size: 12px;
            }

            .container {
                padding: 20px 12px;
            }

            .header h1 {
                font-size: 24px;
            }

            .header > button {
                padding: 10px;
                font-size: 12px;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .form {
                padding: 18px;
            }
        }
    </style>
</head>

<body>

<!-- SIDEBAR -->
<div class="sidebar" id="sidebar">

    <div class="sidebar-header">
        <div class="sidebar-title">
            MANJARE
            <span>TOURS &amp; TRAVELS</span>
        </div>

        <button type="button" class="close-btn"
                onclick="closeSidebar()">×</button>
    </div>

    <ul class="sidebar-menu">
        <li><a href="dashboard.jsp"><span class="sidebar-icon">🏠</span>Dashboard</a></li>
        <li><a href="vehicles.jsp"><span class="sidebar-icon">🚗</span>Vehicles</a></li>
        <li><a href="drivers.jsp"><span class="sidebar-icon">👨‍✈️</span>Drivers</a></li>
        <li><a href="customers.jsp"><span class="sidebar-icon">🧳</span>Customers</a></li>
        <li><a href="trips.jsp"><span class="sidebar-icon">🛣️</span>Trips</a></li>
        <li><a href="expenses.jsp"><span class="sidebar-icon">💰</span>Expenses</a></li>
        <li><a href="payments.jsp"><span class="sidebar-icon">💳</span>Payments</a></li>
        <li><a href="reports.jsp"><span class="sidebar-icon">📊</span>Reports</a></li>
        <li><a href="maintenance.jsp"><span class="sidebar-icon">🔧</span>Vehicle Maintenance</a></li>
    </ul>
</div>

<div class="overlay" id="overlay" onclick="closeSidebar()"></div>

<!-- NAVBAR -->
<div class="navbar">
    <div class="nav-left">
        <button type="button" class="menu-btn"
                onclick="openSidebar()" aria-label="Open navigation menu">
            <span></span>
            <span></span>
            <span></span>
        </button>

        <div class="logo">
            MANJARE
            <span>TOURS &amp; TRAVELS</span>
        </div>
    </div>

    <a href="dashboard.jsp" class="back">← Dashboard</a>
</div>

<div class="container">

    <div class="header">
        <h1>💳 Payments</h1>

        <button type="button" onclick="showForm()">
            + Add Payment
        </button>
    </div>

    <!-- STATUS MESSAGES -->
    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");

        if ("added".equals(success)) {
    %>
        <div class="message">Payment added successfully.</div>
    <%
        } else if ("updated".equals(success)) {
    %>
        <div class="message">Payment updated successfully.</div>
    <%
        } else if ("deleted".equals(success)) {
    %>
        <div class="message">Payment deleted successfully.</div>
    <%
        } else if ("notfound".equals(error)) {
    %>
        <div class="message">The selected payment could not be found.</div>
    <%
        } else if ("database".equals(error)) {
    %>
        <div class="message">
            Unable to process the payment. Please check the entered details and try again.
        </div>
    <%
        }
    %>

    <!-- ADD / EDIT PAYMENT FORM -->
    <div class="form" id="paymentForm">

        <h2 id="formTitle">Add Payment</h2>

        <form action="PaymentServlet" method="post" id="paymentEntryForm">

            <input type="hidden" name="action" id="action" value="add">
            <input type="hidden" name="paymentId" id="paymentId" value="">

            <div class="grid">

                <div>
                    <label for="tripId">Trip</label>

                    <select name="tripId" id="tripId" required>
                        <option value="">Select Trip</option>

                        <%
                            try (
                                Connection tripCon = DBConnection.getConnection();
                                PreparedStatement tripPs = tripCon.prepareStatement(
                                    "SELECT t.trip_id, c.name AS customer_name, " +
                                    "t.pickup, t.destination " +
                                    "FROM trips t " +
                                    "LEFT JOIN customers c ON t.customer_id = c.customer_id " +
                                    "ORDER BY t.trip_id DESC"
                                );
                                ResultSet tripRs = tripPs.executeQuery()
                            ) {
                                while (tripRs.next()) {
                                    int tripOptionId = tripRs.getInt("trip_id");
                                    String customerName = tripRs.getString("customer_name");
                                    String pickup = tripRs.getString("pickup");
                                    String destination = tripRs.getString("destination");
                        %>
                            <option value="<%= tripOptionId %>">
                                Trip #<%= tripOptionId %> -
                                <%= escapeHtml(customerName == null ? "Unknown customer" : customerName) %> -
                                <%= escapeHtml(pickup == null ? "Pickup unavailable" : pickup) %>
                                →
                                <%= escapeHtml(destination == null ? "Destination unavailable" : destination) %>
                            </option>
                        <%
                                }
                            } catch (Exception e) {
                                application.log("Unable to load trips for payments.", e);
                            }
                        %>
                    </select>
                </div>

                <div>
                    <label for="amount">Amount (₹)</label>

                    <input type="number"
                           name="amount"
                           id="amount"
                           step="0.01"
                           min="0.01"
                           placeholder="Enter amount"
                           required>
                </div>

                <div>
                    <label for="paymentMode">Payment Mode</label>

                    <select name="paymentMode" id="paymentMode" required>
                        <option value="Cash">Cash</option>
                        <option value="UPI">UPI</option>
                        <option value="Card">Card</option>
                        <option value="Bank Transfer">Bank Transfer</option>
                    </select>
                </div>

                <div>
                    <label for="paymentStatus">Payment Status</label>

                    <select name="paymentStatus" id="paymentStatus" required>
                        <option value="Paid">Paid</option>
                        <option value="Pending">Pending</option>
                        <option value="Refunded">Refunded</option>
                    </select>
                </div>

                <div>
                    <label for="paymentDate">Payment Date</label>

                    <input type="date"
                           name="paymentDate"
                           id="paymentDate"
                           required>
                </div>

            </div>

            <div class="form-buttons">
                <button type="submit" class="save" id="saveButton">
                    Save Payment
                </button>

                <button type="button" class="cancel" onclick="cancelForm()">
                    Cancel
                </button>
            </div>

        </form>
    </div>

    <!-- PAYMENTS TABLE -->
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Trip</th>
                    <th>Customer</th>
                    <th>Amount</th>
                    <th>Mode</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody>
                <%
                    boolean hasPayments = false;

                    try (
                        Connection paymentCon = DBConnection.getConnection();
                        PreparedStatement paymentPs = paymentCon.prepareStatement(
                            "SELECT p.payment_id, p.trip_id, t.customer_id, " +
                            "c.name AS customer_name, p.amount, p.payment_mode, " +
                            "p.payment_status, p.payment_date " +
                            "FROM payments p " +
                            "LEFT JOIN trips t ON p.trip_id = t.trip_id " +
                            "LEFT JOIN customers c ON t.customer_id = c.customer_id " +
                            "ORDER BY p.payment_id DESC"
                        );
                        ResultSet paymentRs = paymentPs.executeQuery()
                    ) {
                        while (paymentRs.next()) {
                            hasPayments = true;

                            int currentPaymentId = paymentRs.getInt("payment_id");
                            int currentTripId = paymentRs.getInt("trip_id");

                            String currentCustomer = paymentRs.getString("customer_name");
                            String currentAmount = paymentRs.getBigDecimal("amount") == null
                                    ? "" : paymentRs.getBigDecimal("amount").toPlainString();

                            String currentMode = paymentRs.getString("payment_mode");
                            String currentStatus = paymentRs.getString("payment_status");

                            Date currentDate = paymentRs.getDate("payment_date");
                            String currentDateString = currentDate == null
                                    ? "" : currentDate.toString();

                            String statusClass = "status-pending";

                            if ("Paid".equalsIgnoreCase(currentStatus)) {
                                statusClass = "status-paid";
                            } else if ("Refunded".equalsIgnoreCase(currentStatus)) {
                                statusClass = "status-refunded";
                            }
                %>
                    <tr>
                        <td><%= currentPaymentId %></td>

                        <td>#<%= currentTripId %></td>

                        <td><%= escapeHtml(currentCustomer == null ? "Unknown customer" : currentCustomer) %></td>

                        <td>₹<%= escapeHtml(currentAmount) %></td>

                        <td><%= escapeHtml(currentMode) %></td>

                        <td>
                            <span class="status <%= statusClass %>">
                                <%= escapeHtml(currentStatus) %>
                            </span>
                        </td>

                        <td><%= escapeHtml(currentDateString) %></td>

                        <td>
                            <div class="actions">

                                <button type="button"
                                        class="edit-btn"
                                        data-id="<%= currentPaymentId %>"
                                        data-trip="<%= currentTripId %>"
                                        data-amount="<%= escapeHtml(currentAmount) %>"
                                        data-mode="<%= escapeHtml(currentMode) %>"
                                        data-status="<%= escapeHtml(currentStatus) %>"
                                        data-date="<%= escapeHtml(currentDateString) %>"
                                        onclick="editPayment(this)">
                                    Edit
                                </button>

                                <form action="PaymentServlet"
                                      method="post"
                                      onsubmit="return confirm('Are you sure you want to delete this payment?');">

                                    <input type="hidden" name="action" value="delete">

                                    <input type="hidden"
                                           name="paymentId"
                                           value="<%= currentPaymentId %>">

                                    <button type="submit" class="delete-btn">
                                        Delete
                                    </button>
                                </form>

                            </div>
                        </td>
                    </tr>
                <%
                        }

                        if (!hasPayments) {
                %>
                    <tr>
                        <td colspan="8" class="empty-message">
                            No payments found. Click "+ Add Payment" to record your first payment.
                        </td>
                    </tr>
                <%
                        }

                    } catch (Exception e) {
                        application.log("Unable to load payments.", e);
                %>
                    <tr>
                        <td colspan="8" class="empty-message">
                            Unable to load payments. Please check the database connection and server logs.
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
    function showForm() {
        resetPaymentForm();

        const form = document.getElementById("paymentForm");
        form.style.display = "block";

        form.scrollIntoView({
            behavior: "smooth",
            block: "start"
        });
    }

    function resetPaymentForm() {
        document.getElementById("paymentEntryForm").reset();

        document.getElementById("action").value = "add";
        document.getElementById("paymentId").value = "";

        document.getElementById("formTitle").textContent = "Add Payment";
        document.getElementById("saveButton").textContent = "Save Payment";
    }

    function editPayment(button) {
        document.getElementById("paymentForm").style.display = "block";

        document.getElementById("action").value = "update";
        document.getElementById("paymentId").value = button.dataset.id;

        document.getElementById("tripId").value = button.dataset.trip;
        document.getElementById("amount").value = button.dataset.amount;
        document.getElementById("paymentMode").value = button.dataset.mode;
        document.getElementById("paymentStatus").value = button.dataset.status;
        document.getElementById("paymentDate").value = button.dataset.date;

        document.getElementById("formTitle").textContent =
            "Edit Payment #" + button.dataset.id;

        document.getElementById("saveButton").textContent = "Update Payment";

        document.getElementById("paymentForm").scrollIntoView({
            behavior: "smooth",
            block: "start"
        });
    }

    function cancelForm() {
        resetPaymentForm();
        document.getElementById("paymentForm").style.display = "none";
    }

    function openSidebar() {
        document.getElementById("sidebar").classList.add("active");
        document.getElementById("overlay").classList.add("active");
    }

    function closeSidebar() {
        document.getElementById("sidebar").classList.remove("active");
        document.getElementById("overlay").classList.remove("active");
    }
</script>

</body>
</html>
