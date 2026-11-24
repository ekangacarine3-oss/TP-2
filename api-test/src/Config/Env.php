<?php
declare(strict_types=1);

namespace App\Config;

class Env
{
    public static function load(string $filePath): void
    {
        if (!is_file($filePath) || !is_readable($filePath)) {
            return;
        }
        $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if ($lines === false) {
            return;
        }
        foreach ($lines as $line) {
            $trimmed = trim($line);
            if ($trimmed === '' || str_starts_with($trimmed, '#')) {
                continue;
            }
            $parts = explode('=', $trimmed, 2);
            if (count($parts) !== 2) {
                continue;
            }
            $key = trim($parts[0]);
            $value = trim($parts[1], " \t\n\r\0\x0B\"'");
            if ($key !== '') {
                $_ENV[$key] = $value;
                putenv("{$key}={$value}");
            }
        }
    }

    public static function get(string $key, string $default = ''): string
    {
        $val = $_ENV[$key] ?? getenv($key);
        return ($val === false || $val === null) ? $default : (string) $val;
    }
}
