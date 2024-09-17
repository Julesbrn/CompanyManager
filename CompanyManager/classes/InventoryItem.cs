namespace CompanyManager
{
    public class InventoryItem
    {
        public Int64 inventory_id { get; set; }
        public Int64 product_id { get; set; }
        public Int64 quantity { get; set; }
        public Decimal msrp { get; set; }
        public string name { get; set; }
        public string brand { get; set; }
    }
}
