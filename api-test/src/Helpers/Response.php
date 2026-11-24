<?php
declare(strict_types=1);

namespace App\Helpers;

class Response
{
    public static function json(array $payload, int $statusCode = 200): void
    {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($payload, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function success(mixed $data = null, string $message = '', int $statusCode = 200): void
    {
        $payload = ['success' => true];
        if ($message !== '') {
            $payload['message'] = $message;
        }
        if ($data !== null) {
            $payload['data'] = $data;
        }
        self::json($payload, $statusCode);
    }

    public static function error(string $message, int $statusCode = 400, array $errors = []): void
    {
        $payload = [
            'success' => false,
            'message' => $message,
        ];
        if (!empty($errors)) {
            $payload['errors'] = $errors;
        }
        self::json($payload, $statusCode);
    }

    public static function getJsonInput(): array
    {
        $raw = file_get_contents('php://input');
        if ($raw === false || trim($raw) === '') {
            return [];
        }
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }
}
