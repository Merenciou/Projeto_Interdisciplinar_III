const SERVER_PORT = process.env.SERVER_PORT || 3000;
const SERVER_HOST = process.env.SERVER_HOST || 'localhost';
const express = require('express');
const cors = require('cors');
const connectDB = require('./src/db');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

let db;

console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_PORT:', process.env.DB_PORT);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_USER:', process.env.DB_USER);

const connect = async () => {
  db = await connectDB();

  app.post('/veiculo', async (req, res) => {
    const { placa, nome, cor, ano, modelo, n_chassi, unico_dono } = req.body;

    if (!placa || !nome || !cor || !ano || !modelo || !n_chassi || unico_dono === undefined) {
      return res.status(400).json({ message: 'Todos os campos são obrigatórios!' });
    }

    try {
      await db.query(
        `INSERT INTO veiculo (placa, nome, cor, ano, modelo, n_chassi, unico_dono)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [placa, nome, cor, ano, modelo, n_chassi, unico_dono]
      );

      const row = `placa: ${placa} | nome: ${nome} | cor: ${cor} | ano: ${ano} | modelo: ${modelo} | n_chassi: ${n_chassi} | unico_dono: ${unico_dono}\n`; // ← \n corrigido
      fs.appendFileSync('veiculo.txt', row);

      res.status(201).json({ message: 'Veículo salvo com sucesso.' });
    } catch (err) {
      if (err.code === '23505') {
        return res.status(400).json({ message: 'Placa ou chassi já cadastrado.' });
      }
      res.status(500).json({ message: 'Erro ao salvar o veículo.', erro: err.message });
    }
  });

  app.get('/veiculo/download', (req, res) => {
    const filePath = path.join(__dirname, 'veiculo.txt');

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ message: 'Arquivo não encontrado' });
    }

    res.download(filePath, 'veiculo.txt');
  });

  app.listen(SERVER_PORT, SERVER_HOST, () => {
    console.log(`Servidor rodando em http://${SERVER_HOST}:${SERVER_PORT}`);
  });

  app.get('/veiculo/:placa', async (req, res) => {
    const { placa } = req.params;

    try {
      const result = await db.query(
        `SELECT * FROM veiculo WHERE placa = $1`,
        [placa]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Veículo não encontrado' });
      }

      res.status(200).json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ message: 'Erro ao pesquisar veículo', erro: err.message });
    }
  });

  app.put('/veiculo/:placa', async (req, res) => {
    const { placa } = req.params;
    const { nome, cor, ano, modelo, n_chassi, unico_dono } = req.body;

    if (!nome || !cor || !ano || !modelo || !n_chassi || unico_dono === undefined) {
      return res.status(400).json({ message: 'Todos os campos são obrigatórios' });
    }

    try {
      const result = await db.query(
        `UPDATE veiculo 
         SET nome=$1, cor=$2, ano=$3, modelo=$4, n_chassi=$5, unico_dono=$6 
         WHERE placa=$7`,
        [nome, cor, ano, modelo, n_chassi, unico_dono, placa]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: 'Veículo não encontrado' });
      }

      res.status(200).json({ message: 'Veículo alterado com sucesso' });
    } catch (err) {
      res.status(500).json({ message: 'Erro ao alterar veículo', erro: err.message });
    }
  });

  app.delete('/veiculo/:placa', async (req, res) => {
    const { placa } = req.params;

    try {
      const result = await db.query(
        `DELETE FROM veiculo WHERE placa = $1`,
        [placa]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: 'Veículo não encontrado' });
      }

      res.status(200).json({ message: 'Veículo excluído com sucesso' });
    } catch (err) {
      res.status(500).json({ message: 'Erro ao excluir veículo', erro: err.message });
    }
  });
};

connect().catch((err) => console.error('Erro ao iniciar servidor:', err));