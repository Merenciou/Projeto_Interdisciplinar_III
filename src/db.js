const { Pool } = require("pg");

const pool = new Pool ({
    host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

const connectDB = async () => {
    const client = await pool.connect();

    await client.query(
        `
            CREATE TABLE IF NOT EXISTS veiculo (
            placa TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            cor TEXT NOT NULL,
            ano INTEGER NOT NULL,
            modelo INTEGER NOT NULL,
            n_chassi TEXT NOT NULL UNIQUE,
            unico_dono BOOLEAN NOT NULL
            )
        `
    );
    console.log("Banco de dados conectado.");
    client.release();
    return pool;
    
}

module.exports = connectDB;