
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

    <title>Expenses | Manjare Tours & Travels</title>

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

        .save {
            background: #d4af37;
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
            min-width: 950px;
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

            .header {
                align-items: flex-start;
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
        <li>
            <a href="dashboard.jsp">
                <span class="sidebar-icon">🏠</span> Dashboard
            </a>
        </li>

        <li>
            <a href="vehicles.jsp">
                <span class="sidebar-icon">🚗</span> Vehicles
            </a>
        </li>

        <li>
            <a href="drivers.jsp">
                <span class="sidebar-icon">👨‍✈️</span> Drivers
            </a>
        </li>

        <li>
            <a href="customers.jsp">
                <span class="sidebar-icon">🧳</span> Customers
            </a>
        </li>

        <li>
            <a href="trips.jsp">
                <span class="sidebar-icon">🛣️</span> Trips
            </a>
        </li>

        <li>
            <a href="expenses.jsp">
                <span class="sidebar-icon">💰</span> Expenses
            </a>
        </li>

        <li>
            <a href="payments.jsp">
                <span class="sidebar-icon">💳</span> Payments
            </a>
        </li>

        <li>
            <a href="reports.jsp">
                <span class="sidebar-icon">📊</span> Reports
            </a>
        </li>

        <li>
            <a href="maintenance.jsp">
                <span class="sidebar-icon">🔧</span> Vehicle Maintenance
            </a>
        </li>
    </ul>
</div>

<!-- SIDEBAR OVERLAY -->
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
        <h1>💰 Expenses</h1>

        <button type="button" onclick="showForm()">
            + Add Expense
        </button>
    </div>

    <!-- STATUS MESSAGES -->
    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");

        if ("added".equals(success)) {
    %>
        <div class="message">Expense added successfully.</div>
    <%
        } else if ("updated".equals(success)) {
    %>
        <div class="message">Expense updated successfully.</div>
    <%
        } else if ("deleted".equals(success)) {
    %>
        <div class="message">Expense deleted successfully.</div>
    <%
        } else if ("notfound".equals(error)) {
    %>
        <div class="message">The selected expense could not be found.</div>
    <%
        } else if ("database".equals(error)) {
    %>
        <div class="message">Unable to process the expense. Please check the entered details and try again.</div>
    <%
        }
    %>

    <!-- ADD / EDIT FORM -->
    <div class="form" id="expenseForm">

        <h2 id="formTitle">Add Expense</h2>

        <form action="ExpenseServlet" method="post" id="expenseEntryForm">

            <input type="hidden" name="action" id="action" value="add">
            <input type="hidden" name="expenseId" id="expenseId" value="">

            <div class="grid">

                <div>
                    <label for="vehicleId">Vehicle</label>

                    <select name="vehicleId" id="vehicleId" required>
                        <option value="">Select Vehicle</option>

                        <%
                            try (
                                Connection vehicleCon = DBConnection.getConnection();
                                PreparedStatement vehiclePs = vehicleCon.prepareStatement(
                                    "SELECT vehicle_id, vehicle_number " +
                                    "FROM vehicles ORDER BY vehicle_id DESC"
                                );
                                ResultSet vehicleRs = vehiclePs.executeQuery()
                            ) {
                                while (vehicleRs.next()) {
                        %>
                            <option value="<%= vehicleRs.getInt("vehicle_id") %>">
                                <%= escapeHtml(vehicleRs.getString("vehicle_number")) %>
                            </option>
                        <%
                                }
                            } catch (Exception e) {
                                application.log("Unable to load vehicles for expenses.", e);
                            }
                        %>
                    </select>
                </div>

                <div>
                    <label for="expenseType">Expense Type</label>

                    <select name="expenseType" id="expenseType" required>
                        <option value="Fuel">Fuel</option>
                        <option value="Maintenance">Maintenance</option>
                        <option value="Repair">Repair</option>
                        <option value="Toll">Toll</option>
                        <option value="Insurance">Insurance</option>
                        <option value="Other">Other</option>
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
                    <label for="expenseDate">Expense Date</label>

                    <input type="date"
                           name="expenseDate"
                           id="expenseDate"
                           required>
                </div>

                <div>
                    <label for="description">Description</label>

                    <input type="text"
                           name="description"
                           id="description"
                           maxlength="255"
                           placeholder="Enter description">
                </div>

            </div>

            <div class="form-buttons">
                <button type="submit" class="save" id="saveButton">
                    Save Expense
                </button>

                <button type="button" class="cancel" onclick="cancelForm()">
                    Cancel
                </button>
            </div>

        </form>
    </div>

    <!-- EXPENSES TABLE -->
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Vehicle</th>
                    <th>Expense Type</th>
                    <th>Amount</th>
                    <th>Date</th>
                    <th>Description</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody>
                <%
                    boolean hasExpenses = false;

                    try (
                        Connection expenseCon = DBConnection.getConnection();
                        PreparedStatement expensePs = expenseCon.prepareStatement(
                            "SELECT e.expense_id, e.vehicle_id, v.vehicle_number, " +
                            "e.expense_type, e.amount, e.expense_date, e.description " +
                            "FROM expenses e " +
                            "LEFT JOIN vehicles v ON e.vehicle_id = v.vehicle_id " +
                            "ORDER BY e.expense_id DESC"
                        );
                        ResultSet expenseRs = expensePs.executeQuery()
                    ) {
                        while (expenseRs.next()) {
                            hasExpenses = true;

                            int currentExpenseId = expenseRs.getInt("expense_id");
                            int currentVehicleId = expenseRs.getInt("vehicle_id");

                            String currentVehicle = expenseRs.getString("vehicle_number");
                            String currentType = expenseRs.getString("expense_type");
                            String currentAmount = expenseRs.getBigDecimal("amount") == null
                                    ? "" : expenseRs.getBigDecimal("amount").toPlainString();

                            Date currentDate = expenseRs.getDate("expense_date");
                            String currentDateString = currentDate == null
                                    ? "" : currentDate.toString();

                            String currentDescription = expenseRs.getString("description");
                %>
                    <tr>
                        <td><%= currentExpenseId %></td>

                        <td><%= escapeHtml(currentVehicle == null ? "N/A" : currentVehicle) %></td>

                        <td><%= escapeHtml(currentType) %></td>

                        <td>₹<%= escapeHtml(currentAmount) %></td>

                        <td><%= escapeHtml(currentDateString) %></td>

                        <td><%= escapeHtml(currentDescription) %></td>

                        <td>
                            <div class="actions">

                                <button type="button"
                                        class="edit-btn"
                                        data-id="<%= currentExpenseId %>"
                                        data-vehicle="<%= currentVehicleId %>"
                                        data-type="<%= escapeHtml(currentType) %>"
                                        data-amount="<%= escapeHtml(currentAmount) %>"
                                        data-date="<%= escapeHtml(currentDateString) %>"
                                        data-description="<%= escapeHtml(currentDescription) %>"
                                        onclick="editExpense(this)">
                                    Edit
                                </button>

                                <form action="ExpenseServlet"
                                      method="post"
                                      onsubmit="return confirm('Are you sure you want to delete this expense?');">

                                    <input type="hidden" name="action" value="delete">

                                    <input type="hidden"
                                           name="expenseId"
                                           value="<%= currentExpenseId %>">

                                    <button type="submit" class="delete-btn">
                                        Delete
                                    </button>
                                </form>

                            </div>
                        </td>
                    </tr>
                <%
                        }

                        if (!hasExpenses) {
                %>
                    <tr>
                        <td colspan="7" class="empty-message">
                            No expenses found. Click "+ Add Expense" to add your first expense.
                        </td>
                    </tr>
                <%
                        }

                    } catch (Exception e) {
                        application.log("Unable to load expenses.", e);
                %>
                    <tr>
                        <td colspan="7" class="empty-message">
                            Unable to load expenses. Please check the database connection and server logs.
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
        resetExpenseForm();

        const form = document.getElementById("expenseForm");
        form.style.display = "block";

        form.scrollIntoView({
            behavior: "smooth",
            block: "start"
        });
    }

    function resetExpenseForm() {
        document.getElementById("expenseEntryForm").reset();

        document.getElementById("action").value = "add";
        document.getElementById("expenseId").value = "";

        document.getElementById("formTitle").textContent = "Add Expense";
        document.getElementById("saveButton").textContent = "Save Expense";
    }

    function editExpense(button) {
        document.getElementById("expenseForm").style.display = "block";

        document.getElementById("action").value = "update";
        document.getElementById("expenseId").value = button.dataset.id;

        document.getElementById("vehicleId").value = button.dataset.vehicle;
        document.getElementById("expenseType").value = button.dataset.type;
        document.getElementById("amount").value = button.dataset.amount;
        document.getElementById("expenseDate").value = button.dataset.date;
        document.getElementById("description").value = button.dataset.description || "";

        document.getElementById("formTitle").textContent = "Edit Expense #" + button.dataset.id;
        document.getElementById("saveButton").textContent = "Update Expense";

        document.getElementById("expenseForm").scrollIntoView({
            behavior: "smooth",
            block: "start"
        });
    }

    function cancelForm() {
        resetExpenseForm();
        document.getElementById("expenseForm").style.display = "none";
    }

    /* OPEN SIDEBAR */
    function openSidebar() {
        document.getElementById("sidebar").classList.add("active");
        document.getElementById("overlay").classList.add("active");
    }

    /* CLOSE SIDEBAR */
    function closeSidebar() {
        document.getElementById("sidebar").classList.remove("active");
        document.getElementById("overlay").classList.remove("active");
    }
</script>

</body>
</html>
