from utils import *

# for reloading imports after changes
import importlib
import utils
importlib.reload(utils)

######### extracting for sale listings #########
for_sale_all_homes = extract_zillow_data(dropdown1_name="home-sales-listings-dropdown-1",
                         dropdown2_name="home-sales-listings-dropdown-2",
                         dropdown1_value="For-Sale Inventory (Smooth, All Homes, Weekly)",
                         dropdown2_value="Metro & U.S.",
                         download_button="home-sales-listings-download-link"
                         )

# melting dates
df = pd.melt(for_sale_all_homes,
        id_vars = ['RegionID', 'SizeRank', 'RegionName', 'RegionType', 'StateName'],
        var_name='Dates',
        value_name='For_Sale_Inventory_All_Homes')

# saving file
save_file(df, file_name="for_sale_listings_all_homes")

for_sale_sfr = extract_zillow_data(dropdown1_name="home-sales-listings-dropdown-1",
                         dropdown2_name="home-sales-listings-dropdown-2",
                         dropdown1_value="For-Sale Inventory (Smooth, SFR Only, Weekly)",
                         dropdown2_value="Metro & U.S.",
                         download_button="home-sales-listings-download-link")

# df = pd.read_csv('data/for_sale_listings_sfr.csv')

# melting dates
df = pd.melt(for_sale_sfr,
        id_vars = ['RegionID', 'SizeRank', 'RegionName', 'RegionType', 'StateName'],
        var_name='Dates',
        value_name='For_Sale_Inventory_All_Homes')

# saving file
save_file(df, file_name="for_sale_listings_sfr")