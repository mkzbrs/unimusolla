<?php

require_once __DIR__ . '/config.php';

class Database
{
    private static ?PDO $connection = null;

    public static function connect(): PDO
    {
        if (self::$connection === null) {

            self::$connection = new PDO(
                'sqlite:' . DB_PATH
            );

            self::$connection->setAttribute(
                PDO::ATTR_ERRMODE,
                PDO::ERRMODE_EXCEPTION
            );

            self::$connection->setAttribute(
                PDO::ATTR_DEFAULT_FETCH_MODE,
                PDO::FETCH_ASSOC
            );

            self::$connection->exec('PRAGMA foreign_keys = ON');
        }

        return self::$connection;
    }
}
