require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./src/db');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json);

let db;

const connect = async () => {
    db = await connectDB;

    // Talvez tirar essa parte
    app.post('/veiculo', async (req, res) => {
        const { placa, nome, cor, ano, modelo, n_chassi, unico_dono } = req.body;

        if(!placa || !nome || !cor || !ano || !modelo || !n_chassi || unico_dono === undefined) {
            return res.status(400).json({ message: 'Todos os campos são obrigatórios!'});
        }

        try{
            await db.query(
                `
                INSERT INTO veiculo (placa, nome, cor, ano, modelo, n_chassi, unico_dono)
                VALUES ($1,2$,3$,4$,5$,6$,7$)
                `,
                [placa, nome, cor, ano, modelo, n_chassi, unico_dono]
            );

            const row = `placa: ${placa} | nome: ${nome} | cor: ${cor} | ano: ${ano} | modelo: ${modelo} | n_chassi: ${n_chassi} | unico_dono: ${unico_dono}/n`;
            fs.appendFileSync('veiculo.text', row);

            res.status(201).json({ message: 'Veículo salvo com sucesso.'});
        } catch (err) {
            if(err.code === '23505') {
                return res.status(400).json({ message: 'Placa ou chassi já cadastrado.' });
            }
            res.status(500).json({ message: 'Erro ao salvar o veículo.', erro: err.message });
            
        }
    });

    app.get('/veiculo/:placa', async (req, res) => {
        const { placa } = req.params;

        try{
            const result = await db.query(
                `SELECT * FROM veiculo WHERE placa = $1`,
                [placa]
            );

            if(result.row.lenght === 0){
                return res.status(404).json({ message: 'Veículo não encontrado' });
            }

            res.status(200).json(result.row[0]);
        } catch(err) {
            res.status(500).json({ message: 'Erro ao pesquisar veículo', erro: err.message });
        }
    });


}