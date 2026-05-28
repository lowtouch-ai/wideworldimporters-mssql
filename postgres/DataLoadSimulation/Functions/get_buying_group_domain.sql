-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetBuyingGroupDomain.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_buying_group_domain(
    p_buying_group varchar(50)
) RETURNS TABLE(web_domain varchar(256), email_domain varchar(256)) AS $$
BEGIN
    RETURN QUERY
    WITH urls(buying_group_name, web_domain, email_domain) AS (
        VALUES
            ('Datum Corporation'::varchar,                          'http://www.adatum.com/'::varchar,                               'adatum.com'::varchar),
            ('Adventure Works Cycles',                              'http://www.adventure-works.com/',                               'adventure-works.com'),
            ('Alpine Ski House',                                    'http://www.alpineskihouse.com/',                                 'alpineskihouse.com'),
            ('Bellows College',                                     'http://www.bellowscollege.com',                                  'bellowscollege.com'),
            ('Best For You Organics Company',                       'http://www.bestforyouorganics.com',                             'bestforyouorganics.com'),
            ('Blue Younder Airlines',                               'http://www.blueyonderairlines.com/',                            'blueyonderairlines.com'),
            ('City Power & Light',                                  'http://www.cpandl.com/',                                        'cpandl.com'),
            ('Coho Vineyard',                                       'http://www.cohovineyard.com/',                                  'cohovineyard.com'),
            ('Coho Winery',                                         'http://www.cohowinery.com/',                                    'cohowinery.com'),
            ('Coho Vineyard & Winery',                              'http://www.cohovineyardandwinery.com/',                         'cohovineyardandwinery.com'),
            ('Contoso, Ltd.',                                       'http://www.contoso.com/',                                       'contoso.com'),
            ('Contoso Pharmaceuticals',                             'http://www.contoso.com/',                                       'contoso.com'),
            ('Contoso Suites',                                      'http://www.contososuites.com',                                  'contososuites.com'),
            ('Consolidated Messenger',                              'http://www.consolidatedmessenger.com/',                         'consolidatedmessenger.com'),
            ('Fabrikam, Inc.',                                      'http://www.fabrikam.com/',                                      'fabrikam.com'),
            ('Fabrikam Residences',                                 'http://fabrikamresidences.com',                                 'fabrikamresidences.com'),
            ('First Up Consultants',                                'http://firstupconsultants.com',                                 'firstupconsultants.com'),
            ('Fourth Coffee',                                       'http://www.fourthcoffee.com/',                                  'fourthcoffee.com'),
            ('Graphic Design Institute',                            'http://www.graphicdesigninstitute.com/',                        'graphicdesigninstitute.com'),
            ('Humongous Insurance',                                 'http://www.humongousinsurance.com/',                            'humongousinsurance.com'),
            ('Lamna Healthcare Company',                            'http://www.lamnahealtcare.com',                                 'lamnahealtcare.com'),
            ('Litware, Inc.',                                       'http://www.litwareinc.com/',                                    'litwareinc.com'),
            ('Liberty''s Delightful Sinful Bakery & Cafe',          'http://www.libertysdelightfulsinfulbakeryandcafe.com',          'libertysdelightfulsinfulbakeryandcafe.com'),
            ('Lucerne Publishing',                                  'http://www.lucernepublishing.com/',                             'lucernepublishing.com'),
            ('Margie''s Travel',                                    'http://www.margiestravel.com/',                                 'margiestravel.com'),
            ('Munson''s Pickles and Preserves Farm',                'http://www.munsonspicklesandpreservesfarm.com',                 'munsonspicklesandpreservesfarm.com'),
            ('Nod Publishers',                                      'http://www.nodpublishers.com',                                  'nodpublishers.com'),
            ('Northwind Electric Cars',                             'http://www.northwindelectriccars.com',                          'northwindelectriccars.com'),
            ('Northwind Traders',                                   'http://www.northwindtraders.com/',                              'northwindtraders.com'),
            ('Proseware, Inc.',                                     'http://www.proseware.com/',                                     'proseware.com'),
            ('Relecloud',                                           'http://www.relecloud.com',                                      'relecloud.com'),
            ('School of Fine Art',                                  'http://www.fineartschool.net',                                  'fineartschool.net'),
            ('Southridge Video',                                    'http://www.southridgevideo.com/',                               'southridgevideo.com'),
            ('Tailspin Toys',                                       'http://www.tailspintoys.com/',                                  'tailspintoys.com'),
            ('Trey Research',                                       'http://www.treyresearch.net/',                                  'treyresearch.net'),
            ('The Phone Company',                                   'http://www.thephone-company.com/',                              'thephone-company.com'),
            ('VanArsdel, Ltd.',                                     'http://www.vanarsdelltd.com',                                   'vanarsdelltd.com'),
            ('Wide World Importers',                                'http://www.wideworldimporters.com/',                            'wideworldimporters.com'),
            ('Wingtip Toys',                                        'http://wingtiptoys.com/',                                       'wingtiptoys.com'),
            ('Woodgrove Bank',                                      'http://www.woodgrovebank.com/',                                 'woodgrovebank.com'),
            ('Individual Buyer',                                    'N/A',                                                           'N/A')
    )
    SELECT u.web_domain, u.email_domain
    FROM urls u
    WHERE u.buying_group_name = p_buying_group
    UNION ALL
    SELECT 'N/A', 'N/A'
    WHERE NOT EXISTS (SELECT 1 FROM urls WHERE buying_group_name = p_buying_group)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
