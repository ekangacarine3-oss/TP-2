<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Config\Database;
use App\Helpers\Response;
use PDO;

class AccountController
{
    public function register(): void
    {
        $input = Response::getJsonInput();
        if (empty($input)) {
            $input = $_POST;
        }

        $email = trim((string) ($input['email'] ?? ''));
        $password = (string) ($input['password'] ?? '');

        if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Response::error('Adresse email invalide ou manquante.', 422);
        }
        if (strlen($password) < 6) {
            Response::error('Le mot de passe doit contenir au moins 6 caractères.', 422);
        }

        $pdo = Database::getConnection();
        $checkStmt = $pdo->prepare('SELECT id FROM account WHERE email = :email LIMIT 1');
        $checkStmt->execute([':email' => $email]);
        if ($checkStmt->fetch()) {
            Response::error('Un compte existe déjà avec cette adresse email.', 409);
        }

        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $insertStmt = $pdo->prepare('INSERT INTO account (email, password) VALUES (:email, :password)');
        $insertStmt->execute([':email' => $email, ':password' => $hashedPassword]);

        Response::success(
            ['id' => (int) $pdo->lastInsertId(), 'email' => $email],
            'Compte créé avec succès.',
            201
        );
    }

    public function login(): void
    {
        $input = Response::getJsonInput();
        if (empty($input)) {
            $input = $_POST;
        }

        $email = trim((string) ($input['email'] ?? ''));
        $password = (string) ($input['password'] ?? '');

        if ($email === '' || $password === '') {
            Response::error('Veuillez renseigner votre email et votre mot de passe.', 422);
        }

        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id, email, password, created_at FROM account WHERE email = :email LIMIT 1');
        $stmt->execute([':email' => $email]);
        $account = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$account || !password_verify($password, (string) $account['password'])) {
            Response::error('Email ou mot de passe incorrect.', 401);
        }

        Response::success(
            [
                'id' => (int) $account['id'],
                'email' => $account['email'],
                'created_at' => $account['created_at'],
            ],
            'Connexion réussie.',
            200
        );
    }
}
