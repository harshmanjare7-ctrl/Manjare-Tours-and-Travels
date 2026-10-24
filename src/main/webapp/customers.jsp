<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.manjare.DBConnection" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    boolean editMode = false;
    String editLoadError = null;
    String editCustomerId = "";
    String editName = "";
    String editMobile = "";
    String editAddress = "";

    String editParam = request.getParameter("edit");

    if (editParam != null && editParam.matches("\\d+")) {
        String editSql = "SELECT customer_id, name, mobile, address FROM customers WHERE customer_id = ?";
        try (Connection editCon = DBConnection.getConnection();
             PreparedStatement editPs = editCon.prepareStatement(editSql)) {
            editPs.setInt(1, Integer.parseInt(editParam));
            try (ResultSet editRs = editPs.executeQuery()) {
                if (editRs.next()) {
                    editMode = true;
                    editCustomerId = String.valueOf(editRs.getInt("customer_id"));
                    editName = editRs.getString("name");
                    editMobile = editRs.getString("mobile");
                    editAddress = editRs.getString("address");
                } else {
                    editLoadError = "notfound";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            editLoadError = "database";
        }
    } else if (editParam != null) {
        editLoadError = "invalidid";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customers | Manjare Tours & Travels</title>
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

        .container {
            max-width: 1400px;
            margin: auto;
            padding: 35px;
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

        button {
            border: none;
            background: #d4af37;
            color: #07192b;
            padding: 12px 20px;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
        }

        .form-box {
            display: none;
            background: #0b2239;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }

        .form-box h2 {
            color: #d4af37;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            margin-bottom: 7px;
        }

        input,
        textarea {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 5px;
        }

        textarea {
            resize: vertical;
        }

        .save {
            margin-top: 5px;
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

        .message {
            background: #163b55;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
        }

        /* Added only for Edit/Delete actions */
        .action-buttons {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .edit-button,
        .delete-button,
        .cancel-button {
            display: inline-block;
            padding: 8px 12px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            font-size: 13px;
            cursor: pointer;
            border: none;
        }

        .edit-button {
            background: #f4b942;
            color: #07192b;
        }

        .delete-button {
            background: #c0392b;
            color: white;
        }

        .cancel-button {
            background: transparent;
            border: 1px solid #d4af37;
            color: white;
            margin-left: 8px;
        }

        .cancel-button:hover {
            background: #d4af37;
            color: #07192b;
        }

        @media (max-width: 800px) {
            .navbar {
                padding: 0 18px;
            }

            .container {
                padding: 20px;
                overflow-x: auto;
            }

            .page-header h1 {
                font-size: 25px;
            }

            table {
                min-width: 700px;
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
        <button class="close-btn" onclick="closeSidebar()">×</button>
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

<!-- SIDEBAR OVERLAY -->
<div class="overlay" id="overlay" onclick="closeSidebar()"></div>

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

    <a href="dashboard.jsp" class="back-button">← Dashboard</a>
</div>

<div class="container">
    <div class="page-header">
        <h1>👥 Customers</h1>
        <button onclick="showForm()">+ Add Customer</button>
    </div>

    <% if ("added".equals(request.getParameter("success"))) { %>
        <div class="message">Customer added successfully.</div>
    <% } %>

    <% if ("updated".equals(request.getParameter("success"))) { %>
        <div class="message">Customer updated successfully.</div>
    <% } %>

    <% if ("deleted".equals(request.getParameter("success"))) { %>
        <div class="message">Customer deleted successfully.</div>
    <% } %>

    <% if ("database".equals(request.getParameter("error"))) { %>
        <div class="message">Unable to complete the customer operation. The customer may be linked to an existing trip. Check the server console for details.</div>
    <% } %>

    <% if ("notfound".equals(request.getParameter("error")) || "notfound".equals(editLoadError)) { %>
        <div class="message">Customer record was not found.</div>
    <% } %>

    <% if ("invalidid".equals(request.getParameter("error")) || "invalidid".equals(editLoadError)) { %>
        <div class="message">Invalid customer ID.</div>
    <% } %>

    <% if ("invalidaction".equals(request.getParameter("error"))) { %>
        <div class="message">Invalid customer action.</div>
    <% } %>

    <div class="form-box" id="customerForm" style="<%= editMode ? "display:block;" : "" %>">
        <h2><%= editMode ? "Edit Customer" : "Add Customer" %></h2>

        <form action="<%= request.getContextPath() %>/CustomerServlet" method="post">
            <input type="hidden" name="action" value="<%= editMode ? "update" : "add" %>">
            <% if (editMode) { %>
                <input type="hidden" name="customerId" value="<%= escapeHtml(editCustomerId) %>">
            <% } %>

            <div class="form-group">
                <label>Customer Name</label>
                <input type="text" name="name" placeholder="Enter customer name"
                       value="<%= escapeHtml(editName) %>" required>
            </div>

            <div class="form-group">
                <label>Mobile</label>
                <input type="text" name="mobile" placeholder="Enter mobile number"
                       value="<%= escapeHtml(editMobile) %>">
            </div>

            <div class="form-group">
                <label>Address</label>
                <textarea name="address" rows="3" placeholder="Enter address"><%= escapeHtml(editAddress) %></textarea>
            </div>

            <button type="submit" class="save"><%= editMode ? "Update Customer" : "Save Customer" %></button>
            <% if (editMode) { %>
                <a href="customers.jsp" class="cancel-button">Cancel</a>
            <% } %>
        </form>
    </div>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Mobile</th>
                <th>Address</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT * FROM customers ORDER BY customer_id DESC");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("customer_id") %></td>
                <td><%= escapeHtml(rs.getString("name")) %></td>
                <td><%= escapeHtml(rs.getString("mobile")) %></td>
                <td><%= escapeHtml(rs.getString("address")) %></td>
                <td>
                    <div class="action-buttons">
                        <a class="edit-button" href="customers.jsp?edit=<%= rs.getInt("customer_id") %>">Edit</a>
                        <form action="<%= request.getContextPath() %>/CustomerServlet" method="post"
                              onsubmit="return confirm('Are you sure you want to delete this customer?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="customerId" value="<%= rs.getInt("customer_id") %>">
                            <button type="submit" class="delete-button">Delete</button>
                        </form>
                    </div>
                </td>
            </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
            <tr>
                <td colspan="5">Database Error: Unable to load customers. Check the server console.</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
</div>

<script>
/* =========================
   OPEN SIDEBAR
========================= */
function openSidebar() {
    document.getElementById("sidebar").classList.add("active");
    document.getElementById("overlay").classList.add("active");
}

/* =========================
   CLOSE SIDEBAR
========================= */
function closeSidebar() {
    document.getElementById("sidebar").classList.remove("active");
    document.getElementById("overlay").classList.remove("active");
}

function showForm() {
    const form = document.getElementById("customerForm");

    if (form.style.display === "block") {
        form.style.display = "none";
    } else {
        form.style.display = "block";
    }
}
</script>
</body>
</html>
