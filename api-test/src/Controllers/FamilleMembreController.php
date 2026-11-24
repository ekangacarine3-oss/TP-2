<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Config\Database;
use App\Helpers\Response;
use PDO;

class FamilleMembreController
{
    private const ALLOWED_MIME_TYPES = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];
    private const MAX_IMAGE_SIZE = 5 * 1024 * 1024;

    /**
     * GET /famille-membres?q=...&parente=...
     */
    public function index(): void
    {
        $pdo = Database::getConnection();
        $search = trim((string) ($_GET['q'] ?? $_GET['search'] ?? ''));
        $parente = trim((string) ($_GET['parente'] ?? ''));

        $where = [];
        $params = [];

        if ($search !== '') {
            $like = '%' . $search . '%';
            $where[] = '(nom LIKE :q1 OR postnom LIKE :q2 OR prenom LIKE :q3 OR lieu_naissance LIKE :q4 OR parente LIKE :q5)';
            $params[':q1'] = $like;
            $params[':q2'] = $like;
            $params[':q3'] = $like;
            $params[':q4'] = $like;
            $params[':q5'] = $like;
        }

        if ($parente !== '' && strtolower($parente) !== 'tous') {
            $where[] = 'LOWER(parente) = LOWER(:parente)';
            $params[':parente'] = $parente;
        }

        $sql = 'SELECT id, nom, postnom, prenom, lieu_naissance, date_naissance, parente, image, created_at, updated_at
                FROM famille_membre';
        if (!empty($where)) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }
        $sql .= ' ORDER BY id DESC';

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        Response::success(array_map([$this, 'formatRow'], $rows));
    }

    /**
     * GET /famille-membres/stats
     */
    public function stats(): void
    {
        $pdo = Database::getConnection();

        $total = (int) $pdo->query('SELECT COUNT(*) FROM famille_membre')->fetchColumn();
        $accounts = (int) $pdo->query('SELECT COUNT(*) FROM account')->fetchColumn();

        $byParente = $pdo->query(
            'SELECT parente, COUNT(*) AS total
             FROM famille_membre
             GROUP BY parente
             ORDER BY total DESC, parente ASC'
        )->fetchAll(PDO::FETCH_ASSOC);

        $byLieu = $pdo->query(
            'SELECT lieu_naissance, COUNT(*) AS total
             FROM famille_membre
             GROUP BY lieu_naissance
             ORDER BY total DESC, lieu_naissance ASC'
        )->fetchAll(PDO::FETCH_ASSOC);

        foreach ($byParente as &$item) {
            $item['total'] = (int) $item['total'];
        }
        foreach ($byLieu as &$item) {
            $item['total'] = (int) $item['total'];
        }

        Response::success([
            'total_membres' => $total,
            'total_comptes' => $accounts,
            'par_parente' => $byParente,
            'par_lieu' => $byLieu,
        ]);
    }

    public function show(int $id): void
    {
        $pdo = Database::getConnection();
        $row = $this->findById($pdo, $id);
        if (!$row) {
            Response::error('Membre de famille introuvable.', 404);
        }
        Response::success($row);
    }

    public function store(): void
    {
        $input = $this->extractPayload();
        $validated = $this->validateFields($input);
        $imagePath = $this->handleImageUpload();

        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'INSERT INTO famille_membre (nom, postnom, prenom, lieu_naissance, date_naissance, parente, image)
             VALUES (:nom, :postnom, :prenom, :lieu_naissance, :date_naissance, :parente, :image)'
        );
        $stmt->execute([
            ':nom' => $validated['nom'],
            ':postnom' => $validated['postnom'],
            ':prenom' => $validated['prenom'],
            ':lieu_naissance' => $validated['lieu_naissance'],
            ':date_naissance' => $validated['date_naissance'],
            ':parente' => $validated['parente'],
            ':image' => $imagePath,
        ]);

        $created = $this->findById($pdo, (int) $pdo->lastInsertId());
        Response::success($created, 'Membre de famille ajouté avec succès.', 201);
    }

    public function update(int $id): void
    {
        $pdo = Database::getConnection();
        $existing = $this->findById($pdo, $id);
        if (!$existing) {
            Response::error('Membre de famille introuvable.', 404);
        }

        $input = $this->extractPayload();
        $validated = $this->validateFields($input);
        $imagePath = $this->handleImageUpload() ?? $existing['image'];

        $stmt = $pdo->prepare(
            'UPDATE famille_membre
             SET nom = :nom, postnom = :postnom, prenom = :prenom,
                 lieu_naissance = :lieu_naissance, date_naissance = :date_naissance,
                 parente = :parente, image = :image
             WHERE id = :id'
        );
        $stmt->execute([
            ':nom' => $validated['nom'],
            ':postnom' => $validated['postnom'],
            ':prenom' => $validated['prenom'],
            ':lieu_naissance' => $validated['lieu_naissance'],
            ':date_naissance' => $validated['date_naissance'],
            ':parente' => $validated['parente'],
            ':image' => $imagePath,
            ':id' => $id,
        ]);

        Response::success($this->findById($pdo, $id), 'Membre de famille modifié avec succès.', 200);
    }

    public function destroy(int $id): void
    {
        $pdo = Database::getConnection();
        if (!$this->findById($pdo, $id)) {
            Response::error('Membre de famille introuvable.', 404);
        }
        $stmt = $pdo->prepare('DELETE FROM famille_membre WHERE id = :id');
        $stmt->execute([':id' => $id]);

        Response::success(['id' => $id], 'Membre de famille supprimé avec succès.', 200);
    }

    private function extractPayload(): array
    {
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        if (stripos($contentType, 'application/json') !== false) {
            return Response::getJsonInput();
        }
        return !empty($_POST) ? $_POST : Response::getJsonInput();
    }

    private function validateFields(array $input): array
    {
        $fields = ['nom', 'postnom', 'prenom', 'lieu_naissance', 'date_naissance', 'parente'];
        $errors = [];
        $clean = [];

        foreach ($fields as $field) {
            $value = trim((string) ($input[$field] ?? ''));
            if ($value === '') {
                $errors[$field] = "Le champ {$field} est obligatoire.";
            }
            $clean[$field] = $value;
        }

        if ($clean['date_naissance'] !== '' && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $clean['date_naissance'])) {
            $errors['date_naissance'] = 'La date de naissance doit être au format AAAA-MM-JJ.';
        }

        if (!empty($errors)) {
            Response::error('Données invalides.', 422, $errors);
        }
        return $clean;
    }

    private function handleImageUpload(): ?string
    {
        if (empty($_FILES['image']) || ($_FILES['image']['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
            return null;
        }
        $file = $_FILES['image'];
        if ($file['error'] !== UPLOAD_ERR_OK) {
            Response::error('Erreur lors du téléversement de l\'image.', 400);
        }
        if ($file['size'] > self::MAX_IMAGE_SIZE) {
            Response::error('L\'image dépasse la taille maximale autorisée (5 Mo).', 422);
        }
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = $finfo ? finfo_file($finfo, $file['tmp_name']) : '';
        if ($finfo) {
            finfo_close($finfo);
        }
        if (!isset(self::ALLOWED_MIME_TYPES[$mimeType])) {
            Response::error('Format non supporté (JPG, PNG, WEBP uniquement).', 422);
        }
        $ext = self::ALLOWED_MIME_TYPES[$mimeType];
        $uploadDir = dirname(__DIR__, 2) . '/public/uploads';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0775, true);
        }
        $fileName = 'membre_' . uniqid('', true) . '.' . $ext;
        if (!move_uploaded_file($file['tmp_name'], $uploadDir . '/' . $fileName)) {
            Response::error('Impossible d\'enregistrer l\'image.', 500);
        }
        return 'uploads/' . $fileName;
    }

    private function findById(PDO $pdo, int $id): ?array
    {
        $stmt = $pdo->prepare(
            'SELECT id, nom, postnom, prenom, lieu_naissance, date_naissance, parente, image, created_at, updated_at
             FROM famille_membre WHERE id = :id LIMIT 1'
        );
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ? $this->formatRow($row) : null;
    }

    private function formatRow(array $row): array
    {
        $row['id'] = (int) $row['id'];
        return $row;
    }
}
