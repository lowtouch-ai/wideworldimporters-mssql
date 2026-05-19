from fastapi import APIRouter

router = APIRouter(prefix="/web-api", tags=["WebApi"])

from api.routers.webapi import delete_buying_group  # noqa: F401, E402
from api.routers.webapi import delete_city  # noqa: F401, E402
from api.routers.webapi import delete_color  # noqa: F401, E402
from api.routers.webapi import delete_country  # noqa: F401, E402
from api.routers.webapi import delete_customer_category  # noqa: F401, E402
from api.routers.webapi import delete_customer  # noqa: F401, E402
from api.routers.webapi import delete_delivery_method  # noqa: F401, E402
from api.routers.webapi import delete_package_type  # noqa: F401, E402
from api.routers.webapi import delete_payment_method  # noqa: F401, E402
from api.routers.webapi import delete_state_province  # noqa: F401, E402
from api.routers.webapi import delete_stock_group  # noqa: F401, E402
from api.routers.webapi import delete_stock_item  # noqa: F401, E402
from api.routers.webapi import delete_supplier_category  # noqa: F401, E402
from api.routers.webapi import delete_supplier  # noqa: F401, E402
from api.routers.webapi import delete_transaction_type  # noqa: F401, E402
from api.routers.webapi import login  # noqa: F401, E402
from api.routers.webapi import search_for_stock_items  # noqa: F401, E402
