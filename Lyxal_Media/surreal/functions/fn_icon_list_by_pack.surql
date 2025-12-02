DEFINE FUNCTION fn::icon::list_by_pack($pack: string, $limit: number) {
    LET $l = type::number($limit) OR 100;
    RETURN SELECT * FROM icon WHERE pack = $pack LIMIT $l;
};

