<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Manjare Tours & Travels</title>
    <link rel="stylesheet" href="styleerror.css">
</head>

<body class="intro-mode">

<!-- =====================================================
     ANIMATED BACKGROUND
     ===================================================== -->

<div class="animation-background">

    <div class="sky"></div>

    <div class="city"></div>

    <div class="highway"></div>

    <div class="car">
        <img src="car.png" alt="Car">
    </div>

    <div class="wheel">
        <img src="wheel.png" class="back-wheel" alt="Wheel">
        <img src="wheel.png" class="front-wheel" alt="Wheel">
    </div>

</div>


<!-- =====================================================
     DARK OVERLAY
     ===================================================== -->

<div class="background-overlay"></div>


<!-- =====================================================
     MAIN CONTENT
     ===================================================== -->

<div class="page-content">


    <!-- ================= LOGIN ================= -->

    <div class="login-area">

        <div class="login-card">

            <h1>LOGIN</h1>

            <p class="login-subtitle">
                Access your management dashboard
            </p>


            <!-- LOGIN FORM -->

            <form id="loginForm" action="LoginServlet" method="post">


                <!-- Username -->

                <div class="input-group">

                    <label for="username">
                        Username
                    </label>

                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username"
                        required>

                </div>


                <!-- Password -->

                <div class="input-group">

                    <label for="password">
                        Password
                    </label>

                    <div class="password-container">

                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your password"
                            required>

                        <button type="button" id="togglePassword">
                            👁
                        </button>

                    </div>

                </div>


                <!-- Options -->

                <div class="login-options">

                    <label>
                        <input type="checkbox" id="remember">
                        Remember me
                    </label>

                    <a href="forgotPassword.jsp">
                        Forgot Password?
                    </a>

                </div>


                <!-- Login Button -->

                <button
                    type="submit"
                    class="login-button">

                    LOGIN

                </button>


                <!-- Error Message -->

                <p id="message">

                    <%
                        String error =
                            request.getParameter("error");

                        if ("invalid".equals(error)) {
                    %>

                        Invalid username or password.

                    <%
                        }
                    %>

                </p>


            </form>

        </div>

    </div>


    <!-- ================= BRANDING ================= -->

    <div class="branding-area">

        <div class="branding-content">

            <div class="brand-name">
                MANJARE
            </div>

            <div class="brand-subtitle">
                TOURS & TRAVELS
            </div>


            <div class="divider"></div>


            <h2>
                Welcome Back
            </h2>


            <p>
                Manage your trips, vehicles, drivers,
                expenses and payments with ease.
            </p>

        </div>

    </div>


</div>


<!-- JavaScript -->

<script src="error.js"></script>

</body>
</html>