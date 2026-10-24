package com.manjare;

import java.sql.Connection;

public class DBTest {

    public static void main(String[] args) {

        try {

            Connection con =
                    DBConnection.getConnection();

            System.out.println(
                    "DATABASE CONNECTION SUCCESSFUL"
            );

            con.close();

        } catch (Exception e) {

            System.out.println(
                    "DATABASE CONNECTION FAILED"
            );

            e.printStackTrace();
        }
    }
}