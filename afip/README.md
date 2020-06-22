```
{
    "tipo_cbte": Number,
    "punto_venta": Number,
    "fecha": Datetime("%Y%m%d"),
    "concepto": Number,
    "tipo_doc": Number,
    "nro_doc": String,
    "cbte_nro": Number,
    "imp_total": String,
    "imp_tot_conc": String,
    "imp_neto": String,
    "imp_iva": String,
    "imp_trib": String,
    "imp_op_ex": String,
    "imp_subtotal": String,
    "fecha_cbte": Datetime("%Y%m%d"),
    "fecha_venc_pago": Datetime("%Y%m%d"),
    "fecha_serv_desde": Datetime("%Y%m%d"),
    "fecha_serv_hasta": Datetime("%Y%m%d"),
    "moneda_id": String,
    "moneda_ctz": Number,
    "incoterms": String,
    "idioma_cbte": Number,
    "nombre_cliente": String,
    "domicilio_cliente": String,
    "pais_dst_cmp": Number,
    "id_impositivo": String,
    "forma_pago": String,
    "obs_generales": String,
    "obs_comerciales": String,
    "motivo_obs": String,
    "cae": String,
    "fch_venc_cae": Datetime("%Y%m%d"),
    "localidad_cliente": String,
    "provincia_cliente": String,
    "comprobantes_asociados": [
        {
            "tipo": Number,
            "pto_vta": Number,
            "nro": Number
        }
    ],
    "tributos_adicionales": [
        {
            "tributo_id": Number,
            "desc": String,
            "base_imp": String,
            "alic": String,
            "importe": String,

        }
    ],
    "subtotales_iva": [
        {
            "iva_id": Number,
            "base_imp": Number,
            "importe": Number
        }
    ],
    "items": [
        {
            "u_mtx": Number,
            "cod_mtx": Number,
            "codigo": String,
            "ds": String,
            "qty": Number,
            "umed": Number,
            "precio": Number,
            "imp_iva": Number,
            "bonif": Number,
            "iva_id": Number,
            "importe": Number,
            "despacho": String,
            "dato_a": String
        },
        {
            "ds": String,
            "umed": Number,
            "iva_id": Number,
            "imp_iva": Number,
            "importe": Number
        },
        {
            "umed": Number,
            "ds": String
        }
    ],
    "custom-nro-cli": String,
    "custom-pedido": String,
    "custom-remito": String,
    "custom-transporte": String
}
```